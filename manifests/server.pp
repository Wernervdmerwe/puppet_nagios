class nagios::server (
  Boolean $puppetdb_check_enable = $nagios::params::puppetdb_check_enable,
  Boolean $graphios_install = $nagios::params::graphios_install,
  String $graphite_host     = $nagios::params::graphite_host,
  String $config_dir = $nagios::params::config_dir,
  String $log_dir = $nagios::params::log_dir,
  String $perfdata_dir = $nagios::params::perfdata_dir,
  String $date_format = $nagios::params::date_format,
  String $admin_email = $nagios::params::admin_email,
  Integer $debug_level = $nagios::params::debug_level,
  Integer $debug_verbosity = $nagios::params::debug_verbosity,
){

  resources { [ 'nagios_command', 'nagios_contact', 'nagios_contactgroup', 'nagios_host', 'nagios_hostgroup', 'nagios_service' ]:
    purge => true,
  }

  class {'apache':
    purge_configs => false,
    mpm_module    => 'prefork',
  }
  include apache::mod::php

  package { [ 'nagios','nagios-plugins', 'nagios-plugins-nrpe' ]:
    ensure => installed,
  }

  Nagios_contact      { target => '/etc/nagios/objects/contacts.cfg', }
  Nagios_contactgroup { target => '/etc/nagios/objects/contacts.cfg', }
  Nagios_command      { target => '/etc/nagios/conf.d/nagios_command.cfg', }
  Nagios_host         { target => "/etc/nagios/conf.d/${::fqdn}.cfg", }
  Nagios_hostgroup    { target => '/etc/nagios/conf.d/nagios_hostgroup.cfg', }
  Nagios_service      { target => "/etc/nagios/conf.d/${::fqdn}.cfg", }

  $nagios_contacts = hiera_hash('nagios::contacts',undef)
  if $nagios_contacts {
    create_resources (nagios_contact, $nagios_contacts)
  }

  $nagios_hostgroups = hiera_hash('nagios::hostgroups',undef)
  if $nagios_hostgroups {
    create_resources (nagios_hostgroup, $nagios_hostgroups)
  }

  $nagios_contactgroup = hiera_hash('nagios::contactgroup',undef)
  if $nagios_contactgroup {
    create_resources (nagios_contactgroup, $nagios_contactgroup)
  }

  file { '/etc/nagios/nagios.cfg':
    ensure  => 'file',
    content => epp('nagios/nagios.cfg.epp'),
    notify  => Service['nagios'],
  }

  file { '/etc/nagios/conf.d':
    ensure  => 'directory',
    recurse => true,
    mode    => '0664',
  }

  file { [ '/etc/nagios/conf.d/nagios_command.cfg', '/etc/nagios/conf.d/nagios_contact.cfg', '/etc/nagios/conf.d/nagios_host.cfg', '/etc/nagios/conf.d/nagios_hostgroup.cfg', '/etc/nagios/conf.d/nagios_service.cfg' ]:
    ensure => 'file',
    mode   => '0644',
    owner  => 'nagios',
    group  => 'nagios',
  }

  # Deploy nagios_commander
  file {'/usr/local/bin/nagios_commander.sh':
    ensure => 'file',
    mode   => '0777',
    source => 'puppet:///modules/nagios/nagios_commander.sh',
  }

  nagios_command { 'Create NRPE Check':
    ensure       => 'present',
    command_name => 'check_nrpe',
    command_line => '/usr/lib64/nagios/plugins/check_nrpe -H $HOSTADDRESS$ -c $ARG1$',
  }

  service { 'nagios':
    ensure    => 'running',
    subscribe => File['/etc/nagios/conf.d'],
    require   => Package[nagios],
  }

  # Fix permisisons on service file
  file { '/usr/lib/systemd/system/nagios.service':
    ensure => 'file',
    mode   => '0644',
    notify => Service['nagios'],
  }

  # Set hostgroups
  $nagios_hg = hiera(nagios_hostgroup,undef)

  if $nagios_hg {
    $hostgroups = "${::kernel}, ${nagios_hg}"
  }
  else {
    $hostgroups = $::kernel
  }

  @@nagios_host { $::fqdn:
    ensure     => present,
    alias      => $::hostname,
    address    => $::ipaddress,
    use        => 'linux-server',
    hostgroups => $hostgroups,
    target     => "/etc/nagios/conf.d/${::fqdn}.cfg",
    notify     => Service['nagios'],
    tag        => $::environment,
  }

  @@file { "/etc/nagios/conf.d/${::fqdn}.cfg":
    ensure => 'file',
    mode   => '0644',
    owner  => 'nagios',
    group  => 'nagios',
    tag    => $::environment,
  }

  include nagios::collect_checks

  # Configure Puppet node state checks
  if $puppetdb_check_enable == true {
    include nagios::puppetdb
  }

  if $graphios_install == true {
    include nagios::graphios
  }

  $nagios_extra_hosts = hiera(nagios_hosts,undef)
  if $nagios_extra_hosts {
    create_resources(nagios_host, $nagios_extra_hosts)
  }

}
