 # Create a Nagios plugin that queries JBOSS metrics from a server

class nagios::plugin::check_jboss (
  Integer $notification_interval = 'nagios::notification_interval',
  String $notification_period    = 'nagios::notification_period',
){
  # Windows hostnames must be forced to lowercase in order to match the Puppet DB certname
  @@nagios_service { "check_jboss_server_status_${facts['hostname'].downcase}":
    check_command         => 'check_jboss!server_status!admin!admin',
    service_description   => 'JBoss Server Connectivity Check',
    host_name             => $trusted['certname'],
    notify                => Service['nagios'],
    tag                   => $nagios::tag,
    notification_interval => $notification_interval,
    notification_period   => $notification_period,
    require               => Class['nagios'],
  }
  @@nagios_service { "check_jboss_heap_usage_${facts['hostname'].downcase}":
    check_command         => 'check_jboss!heap_usage!admin!admin',
    service_description   => 'JBoss Server heap_usage Check',
    host_name             => $trusted['certname'],
    notify                => Service['nagios'],
    tag                   => $nagios::tag,
    notification_interval => $notification_interval,
    notification_period   => $notification_period,
    require               => Class['nagios'],
  }
  @@nagios_service { "check_jboss_non_heap_usage_${facts['hostname'].downcase}":
    check_command         => 'check_jboss!non_heap_usage!admin!admin',
    service_description   => 'JBoss Server non_heap_usage Check',
    host_name             => $trusted['certname'],
    notify                => Service['nagios'],
    tag                   => $nagios::tag,
    notification_interval => $notification_interval,
    notification_period   => $notification_period,
    require               => Class['nagios'],
  }
  @@nagios_service { "check_jboss_code_cache_usage_${facts['hostname'].downcase}":
    check_command         => 'check_jboss!code_cache_usage!admin!admin',
    service_description   => 'JBoss Server code_cache_usage Check',
    host_name             => $trusted['certname'],
    notify                => Service['nagios'],
    tag                   => $nagios::tag,
    notification_interval => $notification_interval,
    notification_period   => $notification_period,
    require               => Class['nagios'],
  }
  @@nagios_service { "check_jboss_deployment_status_${facts['hostname'].downcase}":
    check_command         => 'check_jboss!deployment_status!admin!admin',
    service_description   => 'JBoss Server deployment_status Check',
    host_name             => $trusted['certname'],
    notify                => Service['nagios'],
    tag                   => $nagios::tag,
    notification_interval => $notification_interval,
    notification_period   => $notification_period,
    require               => Class['nagios'],
  }  

  # Deploy Nagios check script
  file { '/usr/lib64/nagios/plugins/check_wildfly.py':
    ensure => 'file',
    mode   => '0755',
    source => 'puppet:///modules/nagios/check_wildfly.py',
  }

  # Add command to $nagios::server::command_config
  nagios_command { 'check_jboss':
    ensure       => 'present',
    # lint:ignore:140chars
    command_line => '/usr/lib64/nagios/plugins/check_wildfly.py -H $HOSTADDRESS$ -A $ARG1$ -P $ARG2$ -u $ARG3$ -p $ARG4$ -W $ARG5$ -C $ARG6$',
    # lint:endignore
    notify       => Service['nagios'],
  }

}
