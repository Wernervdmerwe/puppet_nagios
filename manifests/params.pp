class nagios::params{
  $role = 'client'
  $graphios_install = true
  $graphite_host = '127.0.0.1'
  $slack_service_channel = '#nagios-alerts'
  $slack_host_channel = '#nagios-alerts'
  $puppetdb_check_enable = false
  $config_dir = '/etc/nagios/conf.d'
  $log_dir = '/var/log/nagios/nagios.log'
  $perfdata_dir = '/var/spool/nagios/graphios'
  $date_format = 'us'
  $admin_email = 'DLUnixSystemAdmins@education.govt.nz'
  $debug_level = 256
  $debug_verbosity = 2
}
