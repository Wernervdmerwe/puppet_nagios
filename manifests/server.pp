# Configure Nagios server
class nagios::server (
  String $puppetdb_host,
  String $admin_email,
  Boolean $puppetdb_check_enable,
  Boolean $graphios_install,
  String $log_dir,
  String $date_format,
  Integer $debug_level,
  Integer $debug_verbosity,
  String $command_config,
  String $hostgroup_config,
  String $host_config,
  String $service_config,
  String $contact_config,
  String $contactgroup_config,
  String $timeperiod_config,
  Integer $nrpe_timeout_seconds,
  String $graphios_perfdata_dir  = lookup('nagios::graphios::perfdata_dir'),
  Hash $nagios_extra_hosts       = {}
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

    # Create Nagios template file. This is needed to update the generic-service, so host
    # contacts override service level contacts.
  file { '/etc/nagios/objects/templates.cfg':
    ensure  => 'file',
    content => epp('nagios/templates.cfg.epp'),
    notify  => Service['nagios'],
  }

  # Remove old Nagios objects
  $resource_types = [
    'nagios_command',
    'nagios_contact',
    'nagios_contactgroup',
    'nagios_host',
    'nagios_hostgroup',
    'nagios_service'
  ]

  $resource_types.each |$resource| {
    resources { $resource:
      purge => true,
    }
  }

  # Set default config files for Nagios objects
  Nagios_contact      { target => $contact_config, }
  Nagios_contactgroup { target => $contactgroup_config, }
  Nagios_command      { target => $command_config, }
  Nagios_host         { target => $host_config, }
  Nagios_hostgroup    { target => $hostgroup_config, }
  Nagios_service      { target => $service_config, }

  # Ensure config file targets are created with the correct permisisons
  $config_files = [
    $command_config,
    $hostgroup_config,
    $host_config,
    $service_config,
    $contact_config,
    $contactgroup_config
  ]

  $config_files.each |$path| {
    file { $path:
      ensure => 'file',
      mode   => '0664',
    }
  }

  file { $timeperiod_config:
    ensure => 'file',
    mode   => '0664',
    source => 'puppet:///modules/nagios/nagios_timeperiods.cfg',
  }

  # Set defaults for Nagios_contact
  Nagios_contact {
    host_notification_period      => '24x7',
    service_notification_period   => '24x7',
    service_notification_options  => 'w,u,c,r,f,s',
    host_notification_options     => 'd,u,r,f,s',
    service_notification_commands => 'notify-service-by-email',
    host_notification_commands    => 'notify-host-by-email',
  }

  $nagios_contacts = hiera_hash('nagios::contacts',undef)
  if $nagios_contacts {
    create_resources (nagios_contact, $nagios_contacts)
  }

  $nagios_hostgroups = hiera_hash('nagios::hostgroups',undef)
  if $nagios_hostgroups {
    create_resources (nagios_hostgroup, $nagios_hostgroups)
  }

  $nagios_contactgroups = hiera_hash('nagios::contactgroup',undef)
  if $nagios_contactgroups {
    create_resources (nagios_contactgroup, $nagios_contactgroups)
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
    command_line => "/usr/lib64/nagios/plugins/check_nrpe -H \$HOSTADDRESS$ -c \$ARG1$ -t ${nrpe_timeout_seconds}",
  }

  service { 'nagios':
    ensure  => 'running',
    enable  => true,
    require => Package[nagios],
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
  if $puppetdb_check_enable {
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

  if $nagios_extra_hosts {
    create_resources(nagios_host, $nagios_extra_hosts)
  }

}
