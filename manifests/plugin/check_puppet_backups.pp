# Nagios check for the puppetmaster backups
class nagios::plugin::check_puppet_backups (
  Integer $notification_interval = lookup('nagios::notification_interval'),
  String $notification_period    = lookup('nagios::notification_period')
){
  # Configure nrpe directories first
  include nrpe

# NRPE Command

  nrpe::command { 'check_pe_backups_file':
    ensure  => present,
    command => 'check_file.sh /tmp/puppetmaster_backup.txt',
  }


# Nagios Check
  @@nagios_service { "check pe backups file ${::hostname}":
    service_description   => 'PE Backups',
    check_command         => 'check_nrpe!check_pe_backups_file',
    host_name             => $::fqdn,
    notify                => Service['nagios'],
    tag                   => $::environment,
    notification_interval => $notification_interval,
    notification_period   => $notification_period,
    require               => Class['nagios']
  }
}
