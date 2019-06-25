class nagios::plugin::check_puppetdb_status {
  # Nagios Check
  @@nagios_service { "check_puppetdb_status_${::hostname}":
    check_command       => "check_puppetdb_status",
    service_description => 'Puppet Agent - last run status',
  }
}
