# Export Nagios service for check_memory
class nagios::plugin::nrpe_memory (
  $ensure                        = 'present',
  $warn                          = 90,
  $crit                          = 95,
  Integer $notification_interval = lookup('nagios::notification_interval'),
  String $notification_period    = lookup('nagios::notification_period'),
  String $check_interval         = $nagios::params::check_interval,
  String $max_check_attempts     = $nagios::params::max_check_attempts,
){
  # Configure nrpe directories first
  include nrpe

  nrpe::plugin { 'check_memory':
      ensure => present,
      source => 'puppet:///modules/nagios/check_memory',
      notify => Service['nrpe'],
  }
  
  nrpe::command { 'check_memory':
    ensure  => $ensure,
    command => "check_memory -w ${warn} -c ${crit}";
  }

  @@nagios_service { "check_memory_${::hostname}":
    service_description   => 'Check Memory',
    check_command         => 'check_nrpe!check_memory',
    host_name             => $::fqdn,
    notify                => Service['nagios'],
    tag                   => $::environment,
    notification_interval => $notification_interval,
    notification_period   => $notification_period,
    require               => Class['nagios'],
    check_interval        => $check_interval,
    max_check_attempts    => $max_check_attempts,
  }
}
