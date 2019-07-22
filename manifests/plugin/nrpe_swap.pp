# Export Nagios service for check_swap
class nagios::plugin::nrpe_swap (
  $ensure = 'present',
  $warn = 20,
  $crit = 10
){
  nrpe::command { 'check_swap':
    ensure  => $ensure,
    command => "check_swap -w ${warn} -c ${crit}";
  }

  if $::swapsize {
    @@nagios_service { "check_swap_${::hostname}":
      service_description => 'Swap Usage',
      check_command       => 'check_nrpe!check_swap',
      host_name           => $::fqdn,
      notify              => Service['nagios'],
      tag                 => $nagios::tag,
    }
  }

}
