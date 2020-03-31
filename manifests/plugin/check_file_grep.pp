# Export Nagios service to check yum patching state
# Parameters:
#     $grep_params:   A list of comma-separated queries to grep a particular file for, each query must 
#                     be separated by a pipe | symbol, with the first value the word/phrase to search for,
#                     and the second is the alert level for that phrase, i.e. 'Snapshot failed|Crit,No disk space|Crit,Timeout|Warning'
#
#     $alert_context: A description of this grep check, i.e. 'Gazette'
#
#     $file_path:     The file (full path) to grep through, i.e '/var/log/gazetteDB.log'
#
#
define nagios::plugin::check_file_grep (
  String $grep_params,
  String $alert_context,
  String $file_path,
  Integer $notification_interval = lookup('nagios::notification_interval'),
  String $notification_period    = lookup('nagios::notification_period'),

){
  # Configure nrpe directories first
  include nrpe

# NRPE Command

  nrpe::command { "check_${alert_context}_file":
    ensure  => present,
    command => "grep_file.sh '${alert_context}' '${file_path}' '${grep_params}'",
  }


# Nagios Check
  @@nagios_service { "check ${alert_context} ${file_path} ${::hostname}":
    service_description   => "${alert_context} File Check",
    check_command         => "check_nrpe!check_${alert_context}_file",
    host_name             => $::fqdn,
    notify                => Service['nagios'],
    tag                   => $::environment,
    notification_interval => $notification_interval,
    notification_period   => $notification_period,
    require               => Class['nagios']
  }
}
