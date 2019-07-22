# Export Nagios service to check for zombie processes
class nagios::plugin::nrpe_zombies (
  $warn = 5,
  $crit = 10
){

# NRPE Command
  nrpe::command { 'check_zombies':
    ensure  => present,
    command => "check_procs -w ${warn} -c ${crit} -s Z";
  }

# Nagios Check
  @@nagios_service { "check-zombies_${::hostname}":
    check_command       => 'check_nrpe!check_zombies',
    service_description => 'Zombie Processes',
    host_name           => $::fqdn,
    notify              => Service['nagios'],
    tag                 => $nagios::tag,
  }
}
