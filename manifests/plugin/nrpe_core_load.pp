# Export Nagios service for check_load
class nagios::plugin::nrpe_core_load (
  $warn                          = 3,
  $crit                          = 5,
  Integer $notification_interval = lookup('nagios::notification_interval'),
  String $notification_period    = lookup('nagios::notification_period')
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
  }
}
