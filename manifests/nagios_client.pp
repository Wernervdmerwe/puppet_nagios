class nagios::nagios_client {
  $nagios_hg = hiera(nagios_hostgroup,undef)

  if $nagios_hg { 
    $hostgroups = "${::kernel}, ${nagios_hg}" 
  }
  else { 
    $hostgroups = $::kernel
  }

  $node_checks = hiera_array('classes',undef)
  if $node_checks { hiera_include('classes') }

  package { [ 'nagios-plugins-nrpe', 'nagios-plugins', 'PyYAML' ]: ensure => installed, }

  @@nagios_host { $::fqdn:
    ensure     => present,
    alias      => $::hostname,
    address    => $::ipaddress,
    use        => 'linux-server',
    hostgroups => $hostgroups,
    target     => '/etc/nagios/conf.d/nagios_host.cfg',
    notify     => Service['nagios'],
  }

#  # Service Defaults
#  Nagios_service {
#    host_name => $::fqdn,
#    target    => '/etc/nagios/conf.d/nagios_service.cfg',
#  }

  include nagios::standard_checks
}
