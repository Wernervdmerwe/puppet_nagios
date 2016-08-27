class nagios::plugin::nrpe_procs (
  $warn = 220,
  $crit = 250
){

# NRPE Command
  nrpe::command { 'check_procs_total':
    ensure  => present,
    command => "check_procs -w ${warn} -c ${crit}";
  }

# Nagios Check
  @@nagios_service { "check-procs_${::hostname}":
    check_command       => 'check_nrpe!check_procs_total',
    service_description => 'Current Processes',
  }
}
