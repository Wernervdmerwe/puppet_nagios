class nagios::nagios_nrpe (
  $plugin_packages = ['procs', 'http', 'tcp', 'pgsql'],
){

  include 'nrpe'
  include 'sudo'

  $plugin_packages.each |$plugin| {
    package { "nagios-plugins-${plugin}": }
  }

  nrpe::plugin { 'check_systemd':
    ensure => present,
    source => "puppet:///modules/${module_name}/check_systemd.sh",
  }

  sudo::conf { 'nrpe':
    content  => 'nrpe ALL=(ALL) NOPASSWD: /usr/lib64/nagios/plugins/',
    priority => 10
  }

}
