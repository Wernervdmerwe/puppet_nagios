# Export Nagios service for check_systemd_service
class nagios::plugin::nrpe_systemd_service(
  Array $service_list = ['ntpd', 'sshd'],
){

# NRPE Command
  nrpe::plugin { 'check_systemd_service':
      ensure => present,
      source => 'puppet:///modules/nagios/check_systemd.sh',
      notify => Service['nrpe'],
  }

  nrpe::command { 'check_systemd_service':
    ensure  => present,
    command => 'check_systemd_service "$ARG1$"';
  }

# Nagios Check
  $service_list.each | $service | {
    $command = "check_nrpe!check_systemd_service -a ${service}"

    @@nagios_service { "check-systemd_service-${service} on ${::hostname}":
      check_command       => $command,
      use                 => 'generic-service',
      service_description => 'Systemd service status',
      tag                 => $nagios::tag,
      notify              => Service['nagios'],
      host_name           => $::fqdn,
    }
  }
}
