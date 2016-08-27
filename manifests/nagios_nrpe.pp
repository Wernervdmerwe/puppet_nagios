class nagios::nagios_nrpe {

  include 'nrpe'
  include 'sudo'
  sudo::conf { 'nrpe':
    content  => 'nrpe ALL=(ALL) NOPASSWD: /usr/lib64/nagios/plugins/',
    priority => 10
  }

}
