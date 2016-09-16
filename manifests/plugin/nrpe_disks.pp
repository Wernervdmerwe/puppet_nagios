class nagios::plugin::nrpe_disks (
  $warn = '5%',
  $crit = '2%'
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
