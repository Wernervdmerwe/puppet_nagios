class nagios::collect_checks {
  Nagios_contact {
    host_notification_period      => '24x7',
    service_notification_period   => '24x7',
    service_notification_options  => 'w,u,c,r,f,s',
    host_notification_options     => 'd,u,r,f,s',
    service_notification_commands => 'notify-service-by-email',
    host_notification_commands    => 'notify-host-by-email',
  }

  Nagios_host {
    check_interval => 1,
    retry_interval => 1,
    max_check_attempts => 2,
  }

  Nagios_service {
    check_interval      => 1,
    retry_interval      => 1,
    max_check_attempts  => 3,
    ensure              => 'present',
    use                 => 'generic-service',
    notification_period => '24x7',
  }

  # Collect resources and populate /etc/nagios/nagios_*.cfg
  Nagios_host <<||>> { notify        => Service['nagios'] }
  Nagios_service <<||>> { notify     => Service['nagios'] }
  Nagios_hostextinfo <<||>> { notify => Service['nagios'] }
}
