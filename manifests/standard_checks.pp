class nagios::standard_checks {

  if $::kernel == 'Linux' {
    include nagios::plugin::nrpe_core_load
    include nagios::plugin::nrpe_swap
    include nagios::plugin::nrpe_users
    include nagios::plugin::nrpe_disks
    include nagios::plugin::nrpe_zombies
    include nagios::plugin::nrpe_procs
    include nagios::plugin::nrpe_memory
    include nagios::plugin::nrpe_puppet
    include nagios::plugin::check_ssh
    include nagios::plugin::check_ping
  }

}
