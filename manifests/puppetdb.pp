class nagios::puppetdb (
  $puppetdb_host = $nagios::params::puppetdb_host
){

  # jq is required for JSON parsing
  package { 'jq':
    ensure   => 'installed',
    provider => 'yum',
  }

  file {'/usr/lib64/nagios/plugins/check_puppetdb_state.sh':
    ensure => 'file',
    owner  => 'nagios',
    mode   => '0755',
  }

  # target is set to /etc/nagios/conf.d/nagios_command.cfg in server.pp
  nagios_command { 'check_puppetdb_status':
    ensure       => 'present',
    command_line => '/usr/lib64/nagios/plugins/check_puppetdb_state.sh $HOSTNAME$',
    notify       => Service['nagios'],
  }
}
