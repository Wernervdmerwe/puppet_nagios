# Export Nagios service for check_ssh
class nagios::plugin::check_ssh {

# Nagios Check
  @@nagios_service { "check_ssh_${::hostname}":
      check_command       => 'check_ssh',
      host_name           => $::fqdn,
      notify              => Service['nagios'],
      service_description => 'SSH',
      tag                 => pick($nagios::tag, $::environment),
      require             => Class['nagios'],
  }
}
