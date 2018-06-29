class nagios::plugin::nrpe_yum_filecheck {

# NRPE Command
  nrpe::plugin { 'check_yum_file.sh':
    ensure => present,
    source => 'puppet:///modules/nagios/check_yum_file.sh',
    notify => Service['nrpe'],
  }

  nrpe::command { 'check_yum_file':
    ensure  => present,
    command => 'check_yum_file.sh /tmp/patching_state.tmp',
  }

# Nagios Check
  @@nagios_service { "check-yum_file_${::hostname}":
    check_command       => 'check_nrpe!check_yum_file',
    service_description => 'Yum Patching',
    host_name           =>  $::fqdn,
  }
}
