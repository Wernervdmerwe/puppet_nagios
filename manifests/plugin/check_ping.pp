# Export Nagios service for check_ping
class nagios::plugin::check_ping (
  $warn                          = 30,
  $crit                          = 90,
  Integer $notification_interval = lookup('nagios::notification_interval'),
  String $notification_period    = lookup('nagios::notification_period')
){

# Nagios Check
  @@nagios_service { "check_ping_${::hostname}":
    check_command         => "check_ping!100.0,${warn}%!500.0,${crit}%",
    service_description   => 'PING',
    host_name             => $::fqdn,
    notify                => Service['nagios'],
    tag                   => $::environment,
    notification_interval => $notification_interval,
    notification_period   => $notification_period,
    require               => Class['nagios'],
  }
}
