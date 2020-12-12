# Set defaults for Nagios classes
class nagios::params {
  $role                  = 'client'
  $graphios_install      = true
  $slack_service_channel = '#nagios-alerts'
  $slack_host_channel    = '#nagios-alerts'
  $puppetdb_check_enable = true
  $puppetdb_host         = 'pro-adm9005.moe.govt.nz'
  $log_dir               = '/var/log/nagios/nagios.log'
  $date_format           = 'us'
  $admin_email           = 'DLUnixSystemAdmins@education.govt.nz'
  $debug_level           = 256
  $debug_verbosity       = 2
  $command_config        = '/etc/nagios/nagios_command.cfg'
  $hostgroup_config      = '/etc/nagios/nagios_hostgroup.cfg'
  $host_config           = '/etc/nagios/nagios_host.cfg'
  $service_config        = '/etc/nagios/nagios_service.cfg'
  $contact_config        = '/etc/nagios/nagios_contact.cfg'
  $contactgroup_config   = '/etc/nagios/nagios_contactgroup.cfg'
  $timeperiod_config     = '/etc/nagios/nagios_timeperiods.cfg'
  $nrpe_timeout_seconds  = 30
  $check_interval        = '1'
  $max_check_attempts    = '5'
  $excluded_mount_points = [],
  $notification_interval = 240,
  $notification_period   = '24x7',
}
