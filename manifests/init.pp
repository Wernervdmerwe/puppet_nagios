# Install and configure Nagios server and client.
# $role parameter should be set to 'server' to configure node as a nagios server
class nagios (
  $role           = lookup('nagios::server::role', String, 'first', undef),
  $nagios_servers = lookup('nrpe::allowed_hosts', Array[String], 'first', undef),
  $notify_slack   = false,
  $tag            = $::environment,
){

  if ($role == 'server') {
    include nagios::server

    if ($notify_slack) { include nagios::slack }
  }

  # Configure NRPE agent
  include nagios::nagios_nrpe

  # Export Nagios resources
  include nagios::export_resources
}
