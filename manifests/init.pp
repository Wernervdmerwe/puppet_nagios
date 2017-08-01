class nagios (
  $role = $nagios::params::role,
  $nagios_servers = lookup('nrpe::allowed_hosts', Array[String], 'first', undef)
) inherits nagios::params {

  # Service Defaults
  Nagios_service {
    host_name => $::fqdn,
    target    => "/etc/nagios/conf.d/${::fqdn}.cfg",
  }

  if ($role == 'server') { include nagios::server }
  else { include nagios::nagios_client  }

  # For both server and client
  include nagios::nagios_nrpe
}
