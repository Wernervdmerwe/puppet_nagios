class nagios::params{
  $role = 'client'
  $graphios_install = true
  $graphite_host = '127.0.0.1'
  $slack_service_channel = '#nagios-alerts'
  $slack_host_channel = '#nagios-alerts'
  $puppetdb_check_enable = false
}
