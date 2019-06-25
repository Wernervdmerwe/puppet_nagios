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
  
  @@nagios_host { $::fqdn:
    ensure     => present,
    alias      => $::hostname,
    address    => $::ipaddress,
    use        => 'linux-server',
    hostgroups => $hostgroups,
    target     => "/etc/nagios/conf.d/${::fqdn}.cfg",
    notify     => Service['nagios'],
  }

  @@file { "/etc/nagios/conf.d/${::fqdn}.cfg":
    ensure => 'file',
    mode   => '0644',
    owner  => 'nagios',
    group  => 'nagios',
  }
  
  # Create exported resources for nagios_services
  include nagios::standard_checks
}
