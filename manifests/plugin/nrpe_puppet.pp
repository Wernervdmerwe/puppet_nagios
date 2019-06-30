# Export Nagios service for check_puppetagent
class nagios::plugin::nrpe_puppet(
  $warn = 3600,
  $crit = 9000
){

# NRPE Command
  nrpe::plugin { 'check_puppetagent':
      ensure => present,
      source => 'puppet:///modules/nagios/check_puppetagent',
      notify => Service['nrpe'],
  }

  nrpe::command { 'check_puppetagent':
    ensure  => present,
    sudo    => true,
    command => "check_puppetagent -w ${warn} -c ${crit}";
  }

# Nagios Check
  @@nagios_service { "check-puppet_${::hostname}":
    check_command       => 'check_nrpe!check_puppetagent',
    service_description => 'Puppet',
  }
}
