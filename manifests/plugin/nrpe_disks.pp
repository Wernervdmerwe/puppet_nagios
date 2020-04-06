# Export Nagios service for check_disks
class nagios::plugin::nrpe_disks (
  $warn                          = '5%',
  $crit                          = '2%',
  # lint:ignore:140chars
  $default_check_disks_command = "check_disk -l -L -w ${warn} -c ${crit} -e -f -M -A -X configfs -X cgroup -X selinuxfs -X sysfs -X proc -X mqueue -X binfmt_misc -X devtmpfs",
  # lint:endignore
  Integer $notification_interval       = lookup('nagios::notification_interval'),
  String $notification_period          = lookup('nagios::notification_period'),
  String $check_interval               = $nagios::params::check_interval,
  String $max_check_attempts           = $nagios::params::max_check_attempts,
  Array[String] $excluded_mount_points = $nagios::params::excluded_mount_points
){
  # Configure nrpe directories first
  include nrpe

  $excluded_mount_point_command = $excluded_mount_points.reduce('') | String $acc, String $mount_point | {
    "${acc} -i ${mount_point}"
  }

  $check_disks_command = "${default_check_disks_command}${excluded_mount_point_command}"

  # NRPE Command
  nrpe::command { 'check_disks':
    ensure  => present,
    command => $check_disks_command;
  }

  # Nagios Check
  @@nagios_service { "check-disks_${::hostname}":
    check_command         => 'check_nrpe!check_disks',
    service_description   => 'Free Space',
    host_name             => $::fqdn,
    notify                => Service['nagios'],
    tag                   => $::environment,
    notification_interval => $notification_interval,
    notification_period   => $notification_period,
    require               => Class['nagios'],
    check_interval        => $check_interval,
    max_check_attempts    => $max_check_attempts,
  }
}
