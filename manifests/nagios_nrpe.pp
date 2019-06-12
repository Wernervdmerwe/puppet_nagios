class nagios::nagios_nrpe (
  $plugin_packages = ['procs', 'http', 'tcp', 'pgsql'],
){

  include 'nrpe'
  include 'sudo'

  # Allow nrpe to run with SELinux
  selinux::boolean { 'nagios_run_sudo': }
  selinux::module { 'allow_nrpe_sudo':
  ensure    => 'present',
  source_pp => 'puppet:///modules/nagios/allow_nrpe_sudo.pp',
}

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
