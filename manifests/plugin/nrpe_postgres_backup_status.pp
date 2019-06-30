# Export Nagios service to check Postgres backup status
class nagios::plugin::nrpe_postgres_backup_status {

  nrpe::plugin { 'check_postgres_backup.sh':
      ensure => present,
      source => 'puppet:///modules/nagios/check_postgres_backup.sh',
      notify => Service['nrpe'],
  }

# NRPE Command
  nrpe::command { 'postgres_backup_status':
    ensure  => present,
    command => 'check_postgres_backup.sh';
  }

# Nagios Check
  @@nagios_service {"Check postgres backup status ${::hostname} ${::environment}":
    check_command       => 'check_nrpe!postgres_backup_status',
    service_description => "Postgres backup status on ${::hostname}",
    host_name           => $::fqdn,
    use                 => 'generic-service',
  }
}

