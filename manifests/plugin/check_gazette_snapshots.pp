# Export Nagios service to check yum patching state
class nagios::plugin::check_gazette_snapshots (
  Integer $notification_interval = lookup('nagios::notification_interval'),
  String $notification_period    = lookup('nagios::notification_period'),
  String $snapshot_errors        = 'Snapshot failed|Crit',
){
  # Configure nrpe directories first
  include nrpe

# NRPE Command

  nrpe::command { 'check_gazette_snapshot':
    ensure  => present,
    command => "grep_file.sh 'Gazette' '/var/log/gazetteDB.log' '${snapshot_errors}'",
  }


# Nagios Check
  @@nagios_service { "check yum file ${::hostname}":
    service_description   => 'EdGazette Snapshot Check',
    check_command         => 'check_nrpe!check_gazette_snapshot',
    host_name             => $::fqdn,
    notify                => Service['nagios'],
    tag                   => $::environment,
    notification_interval => $notification_interval,
    notification_period   => $notification_period,
    require               => Class['nagios']
  }
}
