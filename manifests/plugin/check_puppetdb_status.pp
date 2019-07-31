# Check the last report status in Puppet DB. This check is run from the Nagios server.
class nagios::plugin::check_puppetdb_status (
  Integer $notification_interval = lookup('nagios::notification_interval')
){
  # Windows hostnames must be forced to lowercase in order to match the Puppet DB certname
  @@nagios_service { "check_puppetdb_status_${facts['hostname'].downcase}":
    check_command         => 'check_puppetdb_status',
    service_description   => 'Puppet Agent - last run status',
    host_name             => $::fqdn,
    notify                => Service['nagios'],
    tag                   => $::environment,
    notification_interval => $notification_interval,
    require               => Class['nagios'],
  }
}
