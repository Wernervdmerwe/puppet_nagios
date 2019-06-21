class nagios::collect_checks (
  Array $environments = [ $::environment ]
){
  Nagios_contact {
    host_notification_period      => '24x7',
    service_notification_period   => '24x7',
    service_notification_options  => 'w,u,c,r,f,s',
    host_notification_options     => 'd,u,r,f,s',
    service_notification_commands => 'notify-service-by-email',
    host_notification_commands    => 'notify-host-by-email',
  }

  Nagios_host {
    check_interval     => 1,
    retry_interval     => 1,
    max_check_attempts => 2,
    target             => "/etc/nagios/conf.d/${::fqdn}.cfg"
  }

  Nagios_service {
    check_interval      => 1,
    retry_interval      => 1,
    max_check_attempts  => 3,
    ensure              => 'present',
    use                 => 'generic-service',
    notification_period => '24x7',
    target              => "/etc/nagios/conf.d/${::fqdn}.cfg",
    require             => Nagios_host[$::fqdn]
  }

  # Collect resources and populate /etc/nagios/nagios_*.cfg
  # The exported resources must have the tag "$environment" for this to work
  $environments.each | String $env | {
    File <<| tag == $env |>> { notify => Service['nagios'] }
    Nagios_host <<| tag == $env |>> { notify => Service['nagios'] }
    Nagios_service <<| tag == $env |>> { notify => Service['nagios'] }
    Nagios_hostextinfo <<| tag == $env |>> { notify => Service['nagios'] }
  }
}
