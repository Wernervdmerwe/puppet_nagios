class nagios::plugin::nrpe_memory(
  $ensure = 'present',
  $warn = 85,
  $crit = 95
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
    service_description => 'Memory Usage',
    check_command       => 'check_nrpe!check_memory',
  }

}
