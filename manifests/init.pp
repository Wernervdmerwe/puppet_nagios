class nagios (
  $role = $nagios::params::role,
  $nagios_server = undef
) inherits nagios::params {

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
