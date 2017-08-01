class nagios::nagios_client (
  $nagios_servers = $nagios::nagios_servers
){
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
    target     => "/etc/nagios/conf.d/${::fqdn}.cfg",
    notify     => Service['nagios'],
  }

  @@file { "/etc/nagios/conf.d/${::fqdn}.cfg":
    ensure => 'file',
    mode   => '0644',
    owner  => 'nagios',
    group  => 'nagios',
    tag    => 'nagios_clients'
  }


  if $nagios_servers {
    $nagios_servers.each |String $nagios_server| {
      firewalld_rich_rule { "Allow NRPE port from nagios server ${nagios_server}":
        ensure => present,
        source => "${nagios_server}/32",
        action => 'accept',
        port   => {
          'port'     => '5666',
          'protocol' => 'tcp',
        },
      }
    }
  }

  include nagios::standard_checks
}
