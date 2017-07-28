class nagios::plugin::nrpe_disks (
  $warn = '5%',
  $crit = '2%'
){

# NRPE Command
  nrpe::command { 'check_disks':
    ensure  => present,
    command => "check_disk -l -L -w $warn -c $crit -e -f -M -A -X configfs -X cgroup -X selinuxfs -X sysfs -X proc -X mqueue -X binfmt_misc -X devtmpfs";
  }

# Nagios Check
  @@nagios_service { "check-disks_${::hostname}":
    check_command       => 'check_nrpe!check_disks',
    service_description => 'Free Space',
  }
}
