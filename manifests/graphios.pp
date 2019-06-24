class nagios::graphios (
  $graphite_host = $nagios::params::graphite_host
){

  package { ['python-pip','redhat-lsb-core']: ensure => 'installed', }

  package { 'graphios':
    ensure   => 'installed',
    provider => 'pip',
  }

  file {'/var/spool/nagios/graphios':
    ensure => 'directory',
    owner  => 'nagios',
  }

  file { ['/var/spool/nagios/graphios/service-perfdata','/var/spool/nagios/graphios/host-perfdata']:
    ensure => 'file',
    owner  => 'nagios',
  }

  nagios_command { 'graphite_perf_host':
    ensure       => 'present',
    command_line => '/bin/mv /var/spool/nagios/graphios/host-perfdata /var/spool/nagios/graphios/host-perfdata.$TIMET$',
    #target       => '/etc/nagios/conf.d/nagios_command.cfg',
    notify       => Service['nagios'],
  }

  nagios_command { 'graphite_perf_service':
    ensure       => 'present',
    command_line => '/bin/mv /var/spool/nagios/graphios/service-perfdata /var/spool/nagios/graphios/service-perfdata.$TIMET$',
    #target       => '/etc/nagios/conf.d/nagios_command.cfg',
    notify       => Service['nagios'],
  }

  file {'/etc/graphios/graphios.cfg':
    ensure  => 'file',
    #source => 'puppet:///modules/nagios/graphios.cfg',
    content => epp('nagios/graphios.cfg.epp', {graphite_host => $graphite_host }),
    notify  => Service['graphios'],
  }

  systemd::unit_file { 'graphios.service':
    source => 'puppet:///modules/nagios/graphios.service',
    enable => true,
    active => true,
  }

  service { 'graphios':
    ensure  => running,
    require => Package[graphios]
  }
}
