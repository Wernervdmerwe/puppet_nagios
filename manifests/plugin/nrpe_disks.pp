class nagios::plugin::nrpe_disks (
  $warn = '10%',
  $crit = '5%'
){

# NRPE Command
  nrpe::command { 'check_disks':
    ensure  => present,
    command => "check_disk -L -w $warn -c $crit -e -f -M -A";
  }

# Nagios Check
  @@nagios_service { "check-disks_${::hostname}":
    check_command       => 'check_nrpe!check_disks',
    service_description => 'Free Space',
  }
}
