# Export Nagios service for check_systemd_service
class nagios::plugin::nrpe_systemd_service(
  Array $service_list = [ 'ntpd', 'sshd' ],
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
      service_description => "Systemd service ${service} status",
      host_name           => $::fqdn,
      notify              => Service['nagios'],
      tag                 => pick($nagios::tag, $::environment),
      require             => Class['nagios'],
    }
  }
}
