class nagios::plugin::check_ssh {

# Nagios Check
  @@nagios_service { "check_ssh_${::hostname}":
      check_command       => 'check_ssh',
      use                 => 'generic-service',
      host_name           => "$::fqdn",
      service_description => 'SSH',
  }
}
