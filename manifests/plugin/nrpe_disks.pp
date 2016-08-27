class nagios::plugin::nrpe_disks (
  $warn = '15%',
  $crit = '10%'
){

# NRPE Command
  nrpe::command { 'check_disks':
    ensure  => present,
    command => "check_disk -L -w 15% -c 10% -e -f -M -A";
  }

# Nagios Check
  @@nagios_service { "check-disks_${::hostname}":
    check_command       => 'check_nrpe!check_disks',
    service_description => 'Free Space',
  }
}
