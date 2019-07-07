# Export file, host and service resources for Nagios clients
class nagios::export_resources {
  # Set hostgroups for host definition
  $nagios_hg = hiera(nagios_hostgroup,undef)

  if $nagios_hg {
    $hostgroups = "${::kernel}, ${nagios_hg}"
  }
  else {
    $hostgroups = $::kernel
  }

  # TODO: check if we need a different host template for windows servers

  # Create exported resources for Nagios hosts
  @@nagios_host { $trusted['certname']:
    ensure     => present,
    alias      => $trusted['hostname'],
    address    => $facts['ipaddress'],
    use        => 'linux-server',
    hostgroups => $hostgroups,
    tag        => $nagios::tag
  }

  # Create exported resources for Nagios services
  include nagios::standard_checks
}
