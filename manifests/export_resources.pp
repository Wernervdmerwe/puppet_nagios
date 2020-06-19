# Export file, host and service resources for Nagios clients
class nagios::export_resources (
  Integer $notification_interval = lookup('nagios::notification_interval'),
  String $tag = lookup('nagios::tag'),
  String $default_hostgroups = "${facts['kernel']},${facts['agent_specified_environment']},${facts['netzone']},${facts['domain']}"
){
  # Set hostgroups for host definition
  $nagios_hg = hiera(nagios_hostgroup,undef)

  if $nagios_hg {
    $hostgroups = "${default_hostgroups},${nagios_hg}"
  } else {
    $hostgroups = $default_hostgroups
  }

  # TODO: check if we need a different host template for windows servers

  $app_fact = $trusted['extensions']['pp_application']

  if $app_fact == undef {
    file {'/opt/testing':
      ensure  => present,
      content => 'This app_fact is undef'
    }

    $app_fact_contact_group = ''
  }

  else {
    $app_fact_contact_group = "${app_fact}_${::environment}"
  }

  # Create exported resources for Nagios hosts
  @@nagios_host { $trusted['certname']:
    ensure                => present,
    alias                 => $trusted['hostname'],
    address               => $facts['ipaddress'],
    use                   => 'linux-server',
    hostgroups            => $hostgroups,
    tag                   => $tag,
    notification_interval => $notification_interval,
    contact_groups        => "${app_fact_contact_group},admins"
  }

  # Create exported resources for Nagios services
  include nagios::standard_checks
}
