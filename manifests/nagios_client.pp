class nagios::nagios_client {
  $nagios_hg = hiera(nagios_hostgroup,undef)

  if $nagios_hg { $hostgroups = "${::kernel}, ${nagios_hg}" }
  else { $hostgroups = $::kernel }

  $nagios_plugins = hiera_array('nagios_plugins',undef)
  if $nagios_plugins { hiera_include('nagios_plugins') }

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

  include nagios::standard_checks
}
