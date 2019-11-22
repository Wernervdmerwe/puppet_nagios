# Export Nagios service for check_ssh
class nagios::plugin::check_ssh (
  Integer $notification_interval = lookup('nagios::notification_interval'),
  String $notification_period    = lookup('nagios::notification_period')
){

# Nagios Check
  @@nagios_service { "check_ssh_${::hostname}":
      check_command         => 'check_ssh',
      host_name             => $::fqdn,
      notify                => Service['nagios'],
      service_description   => 'SSH',
      tag                   => $::environment,
      notification_interval => $notification_interval,
      notification_period   => $notification_period,
      require               => Class['nagios'],
  }
}
