class nagios (
  $role = hiera(nagios::role,'client')
){

  # Service Defaults
  Nagios_service {
    host_name => $::fqdn,
    target    => '/etc/nagios/conf.d/nagios_service.cfg',
  }

  if ($role == 'server') { include nagios::server }
  else { include nagios::nagios_client  }

  # For both server and client
  include nagios::nagios_nrpe
}
