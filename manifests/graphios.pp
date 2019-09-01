# Install and configure graphios
class nagios::graphios (
  $graphite_host = $nagios::params::graphite_host
){

  package { ['python-pip','redhat-lsb-core']: ensure => 'installed', }

  package { 'graphios':
    ensure   => 'installed',
    provider => 'pip',
  }

  file { $nagios::server::perfdata_dir:
    ensure => 'directory',
    owner  => 'nagios',
  }

  file { ["${nagios::server::perfdata_dir}/service-perfdata","${nagios::server::perfdata_dir}/host-perfdata"]:
    ensure => 'file',
    owner  => 'nagios',
  }

  nagios_command { 'graphite_perf_host':
    ensure       => 'present',
    command_line => "/bin/mv ${nagios::server::perfdata_dir}/host-perfdata ${nagios::server::perfdata_dir}/host-perfdata.\$TIMET\$",
    notify       => Service['nagios'],
  }

  nagios_command { 'graphite_perf_service':
    ensure       => 'present',
    command_line => "/bin/mv ${nagios::server::perfdata_dir}/service-perfdata ${nagios::server::perfdata_dir}/service-perfdata.\$TIMET\$",
    notify       => Service['nagios'],
  }

  file { '/etc/graphios/graphios.cfg':
    ensure  => 'file',
    content => epp('nagios/graphios.cfg.epp', {graphite_host => $graphite_host }),
    notify  => Service['graphios'],
  }

  # Graphios doesn't provide a systemd service file so we need to create one
  systemd::unit_file { 'graphios.service':
    source  => 'puppet:///modules/nagios/graphios.service',
    enable  => true,
    active  => true,
    require => Package['pip','graphios']
  }

  service { 'graphios':
    ensure  => running,
    require => Systemd::Unit_file['graphios.service']
  }
}
