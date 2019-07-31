# Export Nagios service to check yum patching state
class nagios::plugin::nrpe_yum_filecheck (
  Integer $notification_interval = $nagios::params::notification_interval
){

# NRPE Command
  nrpe::plugin { 'check_yum_file.sh':
    ensure => present,
    source => 'puppet:///modules/nagios/check_yum_file.sh',
    notify => Service['nrpe'],
  }

  nrpe::command { 'check_yum_file':
    ensure  => present,
    command => 'check_yum_file.sh /tmp/patching_state.tmp',
  }

# Nagios Check
  @@nagios_service { "check yum file ${::hostname}":
    service_description   => 'Yum Patching',
    check_command         => 'check_nrpe!check_yum_file',
    host_name             => $::fqdn,
    notify                => Service['nagios'],
    tag                   => pick($nagios::tag, $::environment),
    notification_interval => $notification_interval,
    require               => Class['nagios']
  }
}
