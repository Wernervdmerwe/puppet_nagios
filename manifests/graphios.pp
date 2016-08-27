class nagios::graphios (
  $graphite_host = hiera(graphite_host)
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

  augeas { 'Enable Perfdata':
    context => '/files/etc/nagios/nagios.cfg',
    notify  => Service['nagios'],
    changes => [
      'set service_perfdata_file /var/spool/nagios/graphios/service-perfdata',
      'set service_perfdata_file_template DATATYPE::SERVICEPERFDATA\tTIMET::$TIMET$\tHOSTNAME::$HOSTNAME$\tSERVICEDESC::$SERVICEDESC$\tSERVICEPERFDATA::$SERVICEPERFDATA$\tSERVICECHECKCOMMAND::$SERVICECHECKCOMMAND$\tHOSTSTATE::$HOSTSTATE$\tHOSTSTATETYPE::$HOSTSTATETYPE$\tSERVICESTATE::$SERVICESTATE$\tSERVICESTATETYPE::$SERVICESTATETYPE$\tGRAPHITEPREFIX::$_SERVICEGRAPHITEPREFIX$\tGRAPHITEPOSTFIX::$_SERVICEGRAPHITEPOSTFIX$',
      'set service_perfdata_file_mode a',
      'set service_perfdata_file_processing_interval 15',
      'set service_perfdata_file_processing_command graphite_perf_service',
      'set host_perfdata_file /var/spool/nagios/graphios/host-perfdata',
      'set host_perfdata_file_template DATATYPE::HOSTPERFDATA\tTIMET::$TIMET$\tHOSTNAME::$HOSTNAME$\tHOSTPERFDATA::$HOSTPERFDATA$\tHOSTCHECKCOMMAND::$HOSTCHECKCOMMAND$\tHOSTSTATE::$HOSTSTATE$\tHOSTSTATETYPE::$HOSTSTATETYPE$\tGRAPHITEPREFIX::$_HOSTGRAPHITEPREFIX$\tGRAPHITEPOSTFIX::$_HOSTGRAPHITEPOSTFIX$',
      'set host_perfdata_file_mode a',
      'set host_perfdata_file_processing_interval 15',
      'set host_perfdata_file_processing_command graphite_perf_host',
      'set process_performance_data 1',
      ],
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
    ensure => 'file',
    #source => 'puppet:///modules/nagios/graphios.cfg',
    content => epp('nagios/graphios.cfg.epp', {graphite_host => $graphite_host }),
  }

  file {'/etc/init.d/graphios':
    ensure => 'file',
    source => 'puppet:///modules/nagios/graphios.service',
  }

  service { 'graphios':
    ensure  => running,
    require => Package[graphios]
  }
}
