# Export Nagios service for check_load
class nagios::plugin::nrpe_core_load (
  $warn = 3,
  $crit = 5
){

# NRPE Command
  nrpe::command { 'check_load':
    ensure  => present,
    command => "check_load -r -w ${warn} -c ${crit}";
  }

# Nagios Check
  @@nagios_service { "check-load_${::hostname}":
    check_command       => 'check_nrpe!check_load',
    service_description => 'Current Load Per Core',
  }
}
