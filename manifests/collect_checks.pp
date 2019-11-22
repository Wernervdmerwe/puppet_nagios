# Gather the exported resources from Nagios clients and create Nagios hosts and services
class nagios::collect_checks (
  Array $environments         = [ $::environment ],
  String $notification_period = lookup('nagios::notification_period')
){

  # Set defaults for Nagios_host
  Nagios_host {
    check_interval     => 1,
    retry_interval     => 1,
    max_check_attempts => 2,
  }

  # Set defaults for Nagios_service
  Nagios_service {
    check_interval      => 1,
    retry_interval      => 1,
    max_check_attempts  => 3,
    ensure              => 'present',
    use                 => 'generic-service',
    notification_period => $notification_period,
    require             => "Nagios_host[${trusted['certname']}]"
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
