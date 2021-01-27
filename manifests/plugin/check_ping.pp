# Export Nagios service for check_ping
class nagios::plugin::check_ping (
  $warn                          = 30,
  $crit                          = 90,
  Integer $notification_interval = lookup('nagios::notification_interval'),
  String $notification_period    = lookup('nagios::notification_period'),
  String $check_interval         = lookup('nagios::check_interval'),
  String $max_check_attempts     = lookup('nagios::max_check_attempts'),
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
    check_interval        => $check_interval,
    max_check_attempts    => $max_check_attempts,
  }
}
