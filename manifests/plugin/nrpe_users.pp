# Export Nagios service for check_users
class nagios::plugin::nrpe_users (
  $warn                          = 5,
  $crit                          = 10,
  Integer $notification_interval = lookup('nagios::notification_interval')
){

# NRPE Command
  nrpe::command { 'check_users':
    ensure  => present,
    command => "check_users -w ${warn} -c ${crit}";
  }

# Nagios Check
  @@nagios_service { "check-users_${::hostname}":
    check_command         => 'check_nrpe!check_users',
    service_description   => 'Current Users',
    host_name             => $::fqdn,
    notify                => Service['nagios'],
    tag                   => $::environment,
    notification_interval => $notification_interval,
    require               => Class['nagios'],
  }
}
