# Configure Nagios client
class nagios::nagios_nrpe (
  $nagios_servers  = $nagios::nagios_servers,
  $plugin_packages = ['procs', 'http', 'tcp', 'pgsql'],
){

  include 'nrpe'
  include 'sudo'

  # Allow nrpe to run with SELinux
  selinux::boolean { 'nagios_run_sudo': }
  selinux::module { 'allow_nrpe_sudo':
    ensure    => 'present',
    source_te => 'puppet:///modules/nagios/allow_nrpe_sudo.te',
  }

  # Install base NRPE packages
  package { [ 'nagios-plugins-nrpe', 'nagios-plugins', 'PyYAML' ]:
    ensure => installed,
  }

  # Install plugins
  $plugin_packages.each |$plugin| {
    package { "nagios-plugins-${plugin}": }
  }

  # Install additional plugins specified in hiera
  $nagios_plugins = hiera_array('nagios_plugins',undef)

  if $nagios_plugins {
    hiera_include('nagios_plugins')
  }

  nrpe::plugin { 'check_systemd':
    ensure => present,
    source => "puppet:///modules/${module_name}/check_systemd.sh",
  }

  nrpe::plugin { 'check_file.sh':
    ensure => present,
    source => 'puppet:///modules/nagios/check_file.sh',
    notify => Service['nrpe'],
  }

  nrpe::plugin { 'grep_file.sh':
    ensure => present,
    source => 'puppet:///modules/nagios/grep_file.sh',
    notify => Service['nrpe'],
  }

  # Allow NRPE user to run plugin checks as root
  sudo::conf { 'nrpe':
    content  => 'nrpe ALL=(ALL) NOPASSWD: /usr/lib64/nagios/plugins/',
    priority => 10,
  }

  # Allow Nagios server to access NRPE client on port 5666
  if $nagios_servers {
    $nagios_servers.each |String $nagios_server| {
      firewalld_rich_rule { "Allow NRPE port from nagios server ${nagios_server}":
        ensure => present,
        source => "${nagios_server}/32",
        action => 'accept',
        port   => {
          'port'     => '5666',
          'protocol' => 'tcp',
        },
      }
    }
  }

}
