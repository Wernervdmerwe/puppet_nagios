# Export Nagios service for check_memory
class nagios::plugin::nrpe_memory(
  $ensure                        = 'present',
  $warn                          = 85,
  $crit                          = 95,
  Integer $notification_interval = $nagios::params::notification_interval
){
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
    service_description   => 'Memory Usage',
    check_command         => 'check_nrpe!check_memory',
    host_name             => $::fqdn,
    notify                => Service['nagios'],
    tag                   => pick($nagios::tag, $::environment),
    notification_interval => $notification_interval,
    require               => Class['nagios'],
  }

}
