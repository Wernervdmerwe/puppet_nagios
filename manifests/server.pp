# Configure Nagios server
class nagios::server (
  Boolean $puppetdb_check_enable = $nagios::params::puppetdb_check_enable,
  Boolean $graphios_install      = $nagios::params::graphios_install,
  String $graphite_host          = $nagios::params::graphite_host,
  String $config_dir             = $nagios::params::config_dir,
  String $log_dir                = $nagios::params::log_dir,
  String $perfdata_dir           = $nagios::params::perfdata_dir,
  String $date_format            = $nagios::params::date_format,
  String $admin_email            = $nagios::params::admin_email,
  Integer $debug_level           = $nagios::params::debug_level,
  Integer $debug_verbosity       = $nagios::params::debug_verbosity,
){

  # Install Apache (for Nagios web console)
  class {'apache':
    purge_configs => false,
    mpm_module    => 'prefork',
  }
  include apache::mod::php

  # Allow access to Apache
  firewalld_service { 'Allow HTTP':
    ensure  => 'present',
    service => 'http' ,
  }

  # Install the Nagios server packages
  package { [ 'nagios' ]:
    ensure => installed,
  }

  # Remove sample config files
  $sample_files = [
    '/etc/nagios/objects/localhost.cfg',
    '/etc/nagios/objects/windows.cfg',
    '/etc/nagios/objects/switch.cfg',
    '/etc/nagios/objects/printer.cfg',
  ]

  $sample_files.each |$path| {
    file { $path:
      ensure => 'absent',
    }
  }

  # Create main Nagios config file
  file { '/etc/nagios/nagios.cfg':
    ensure  => 'file',
    content => epp('nagios/nagios.cfg.epp'),
    notify  => Service['nagios'],
  }

  # Set default config files for Nagios objects
  Nagios_contact      { target => '/etc/nagios/objects/contacts.cfg', }
  Nagios_contactgroup { target => '/etc/nagios/objects/contacts.cfg', }
  Nagios_command      { target => '/etc/nagios/conf.d/nagios_command.cfg', }
  Nagios_host         { target => "/etc/nagios/conf.d/${::fqdn}.cfg", }
  Nagios_hostgroup    { target => '/etc/nagios/conf.d/nagios_hostgroup.cfg', }
  Nagios_service      { target => "/etc/nagios/conf.d/${::fqdn}.cfg", }

  # Create config directory
  file { '/etc/nagios/conf.d':
    ensure  => 'directory',
    recurse => true,
    mode    => '0664',
  }

  # Ensure config file targets are created with the correct permisisons
  file { [ '/etc/nagios/conf.d/nagios_command.cfg', '/etc/nagios/conf.d/nagios_hostgroup.cfg' ]:
    ensure => 'file',
    mode   => '0644',
    owner  => 'nagios',
    group  => 'nagios',
  }

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

  # Deploy nagios_commander
  file { '/usr/local/bin/nagios_commander.sh':
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

  # Set hostgroups for the local NRPE agent on the Nagios server
  $nagios_hg = hiera(nagios_hostgroup,undef)

  if $nagios_hg {
    $hostgroups = "${::kernel}, ${nagios_hg}"
  }
  else {
    $hostgroups = $::kernel
  }

  # Gather exported resources from NRPE clients
  include nagios::collect_checks

  # Configure Puppet node state checks
  if $puppetdb_check_enable == true {
    include nagios::puppetdb
  }

  if $graphios_install == true {
    include nagios::graphios
  }

  # Add host definitions defined in hiera
  # Example host definition:
  #    nagios::server::nagios_extra_hosts:
  #    dev-srv0053.moest.govt.nz:
  #      ensure: 'present'
  #      alias: 'dev-srv0053.moest.govt.nz'
  #      address: '10.48.65.223'
  #      use: 'windows-server'
  #      hostgroups: 'Windows'
  #      notification_period: 'workhours'
  #      tag: 'development'

  $nagios_extra_hosts = lookup("nagios::server::nagios_extra_hosts")

  if $nagios_extra_hosts {
    create_resources(nagios_host, $nagios_extra_hosts)
  }

}
