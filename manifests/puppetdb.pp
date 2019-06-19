class nagios::puppetdb (
  $puppetdb_host,
){

  # jq is required for JSON parsing
  package { 'jq':
    ensure   => 'installed',
    provider => 'yum',
  }

  # Deploy Nagios check script
  file {'/usr/lib64/nagios/plugins/check_puppetdb_state.sh':
    ensure  => 'file',
    mode    => '0755',
    content => epp('nagios/check_puppetdb_state.sh.epp'),
  }

  # Command definitions are added to /etc/nagios/conf.d/nagios_command.cfg (set in server.pp)
  nagios_command { 'check_puppetdb_status':
    ensure       => 'present',
    command_line => '/usr/lib64/nagios/plugins/check_puppetdb_state.sh $HOSTNAME$',
    notify       => Service['nagios'],
  }

  # Nagios needs root access to read the Puppet agent SSL files (to access the Puppet DB API)
  include sudo

  sudo::conf { 'nagios':
    content  => 'nagios  ALL=(ALL) NOPASSWD: /bin/curl',
    priority => 20
  }

  firewalld_service { 'Allow HTTP':
    ensure  => 'present',
    service => 'http' , }
}
