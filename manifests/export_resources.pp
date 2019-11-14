# Export file, host and service resources for Nagios clients
class nagios::export_resources (
  Integer $notification_interval = lookup('nagios::notification_interval'),
  String $tag = lookup('nagios::tag'),
  String $default_hostgroups = "${facts['kernel']},${facts['agent_specified_environment']},${facts['netzone']},${facts['domain']},${facts['app']}"
){
  # Set hostgroups for host definition
  $nagios_hg = hiera(nagios_hostgroup,undef)

  if $nagios_hg {
    $hostgroups = "${default_hostgroups},${nagios_hg}"
  } else {
    $hostgroups = $default_hostgroups
  }

  # TODO: check if we need a different host template for windows servers

  # Create exported resources for Nagios hosts
  @@nagios_host { $trusted['certname']:
    ensure                => present,
    alias                 => $trusted['hostname'],
    address               => $facts['ipaddress'],
    use                   => 'linux-server',
    hostgroups            => $hostgroups,
    tag                   => $tag,
    notification_interval => $notification_interval,
  }

  # Create exported resources for Nagios services
  include nagios::standard_checks
}
