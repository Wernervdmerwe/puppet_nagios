# Export file, host and service resources for Nagios clients
class nagios::export_resources {
  # Ensure all exported resources are tagged with the correct environment
  tag "$::environment"
  
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
  @@nagios_host { "${facts['fqdn'].downcase}":
    ensure     => present,
    alias      => "${facts['hostname'].downcase}",
    address    => "${facts['ipaddress']}",
    use        => 'linux-server',
    hostgroups => "$hostgroups",
  }
  
  # Create exported resources for Nagios services
  include nagios::standard_checks
}
