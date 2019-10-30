# Install and configure graphios
class nagios::graphios (
  String $graphite_host,
  String $perfdata_dir
){

  package { ['python-pip','redhat-lsb-core']: ensure => 'installed', }

  package { 'graphios':
    ensure   => 'installed',
    provider => 'pip',
  }

  file { $perfdata_dir:
    ensure => 'directory',
    owner  => 'nagios',
  }

  file { ["${perfdata_dir}/service-perfdata","${perfdata_dir}/host-perfdata"]:
    ensure => 'file',
    owner  => 'nagios',
  }

  nagios_command { 'graphite_perf_host':
    ensure       => 'present',
    command_line => "/bin/mv ${perfdata_dir}/host-perfdata ${perfdata_dir}/host-perfdata.\$TIMET\$",
    notify       => Service['nagios'],
  }

  nagios_command { 'graphite_perf_service':
    ensure       => 'present',
    command_line => "/bin/mv ${perfdata_dir}/service-perfdata ${perfdata_dir}/service-perfdata.\$TIMET\$",
    notify       => Service['nagios'],
  }

  file { '/etc/graphios/graphios.cfg':
    ensure  => 'file',
    content => epp('nagios/graphios.cfg.epp', {graphite_host => $graphite_host }),
    notify  => Package['graphios'],
  }

  # Graphios doesn't provide a systemd service file so we need to create one
  systemd::unit_file { 'graphios.service':
    source  => 'puppet:///modules/nagios/graphios.service',
    enable  => true,
    active  => true,
    require => Package['python-pip','graphios']
  }

  ->service { 'graphios': ensure  => running, }
}
