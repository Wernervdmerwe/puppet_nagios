# Check the last report status in Puppet DB. This check is run from the Nagios server.
class nagios::plugin::check_puppetdb_status (
  Integer $notification_interval = lookup('nagios::notification_interval'),
  String $notification_period    = lookup('nagios::notification_period')
){
  # Windows hostnames must be forced to lowercase in order to match the Puppet DB certname
  @@nagios_service { "check_puppetdb_status_${facts['hostname'].downcase}":
    check_command         => 'check_puppetdb_status',
    service_description   => 'Puppet Agent - last run status',
    host_name             => $trusted['certname'],
    notify                => Service['nagios'],
    tag                   => $nagios::tag,
    notification_interval => $notification_interval,
    notification_period   => $notification_period,
    require               => Class['nagios'],
  }
}
