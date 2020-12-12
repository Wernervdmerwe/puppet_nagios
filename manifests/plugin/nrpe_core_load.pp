# Export Nagios service for check_load
class nagios::plugin::nrpe_core_load (
  $warn                          = 3,
  $crit                          = 5,
  Integer $notification_interval = $nagios::notification_interval,
  String $notification_period    = $nagios::notification_period,
  String $check_interval         = $nagios::params::check_interval,
  String $max_check_attempts     = $nagios::params::max_check_attempts,
){
  # Configure nrpe directories first
  include nrpe

  # NRPE Command
  nrpe::command { 'check_load':
    ensure  => present,
    command => "check_load -r -w ${warn} -c ${crit}";
  }

  # Nagios Check
  @@nagios_service { "check-load_${::hostname}":
    check_command         => 'check_nrpe!check_load',
    service_description   => 'Current Load Per Core',
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
