class nagios::slack (
  String $opt_token,
  String $opt_domain,
  String $slack_service_channel = $nagios::params::slack_service_channel,
  String $slack_host_channel = $nagios::params::slack_host_channel,
){
  package {['perl-libwww-perl','perl-Crypt-SSLeay', 'perl-LWP-Protocol-https']:
    ensure => 'installed',
  }

  exec {'Pull down nagios-slack executable':
    path    => $::path,
    command => 'wget -k -O /usr/local/bin/slack_nagios.pl https://raw.github.com/tinyspeck/services-examples/master/nagios.pl',
    creates => '/usr/local/bin/slack_nagios.pl'
  }

  file { '/usr/local/bin/slack_nagios.pl':
    ensure  => 'present',
    mode    => '0755',
    require => Exec['Pull down nagios-slack executable']
  }

  file_line {'Set Slack Domain':
    ensure  => 'present',
    line    => "my \$opt_domain = \"${opt_domain}\";",
    match   => '^my.+opt_domain\s+=',
    path    => '/usr/local/bin/slack_nagios.pl',
    require => Exec['Pull down nagios-slack executable']
  }
  file_line {'Set Slack Token':
    ensure  => 'present',
    line    => "my \$opt_token = \"${opt_token}\";",
    match   => "^my.+opt_token\s+=",
    path    => '/usr/local/bin/slack_nagios.pl',
    require => Exec['Pull down nagios-slack executable']
  }

  nagios_contact {'Create Slack User':
    contact_name                  => 'slack',
    alias                         => 'Slack',
    service_notification_period   => '24x7',
    host_notification_period      => '24x7',
    service_notification_options  => 'w,u,c,r',
    host_notification_options     => 'd,r',
    service_notification_commands => 'notify-service-by-slack',
    host_notification_commands    => 'notify-host-by-slack',
  }

  nagios_command { 'notify-service-by-slack':
    ensure       => 'present',
    command_name => 'notify-service-by-slack',
    command_line => "/usr/local/bin/slack_nagios.pl -field slack_channel=${slack_service_channel} -field HOSTALIAS=\"\$HOSTNAME\$\" -field SERVICEDESC=\"\$SERVICEDESC\$\" -field SERVICESTATE=\"\$SERVICESTATE\$\" -field SERVICEOUTPUT=\"\$SERVICEOUTPUT\$\" -field NOTIFICATIONTYPE=\"\$NOTIFICATIONTYPE\$\"",
  }
  nagios_command { 'notify-host-by-slack':
    ensure       => 'present',
    command_name => 'notify-host-by-slack',
    command_line => "/usr/local/bin/slack_nagios.pl -field slack_channel=${slack_host_channel} -field HOSTALIAS=\"\$HOSTNAME\$\" -field HOSTSTATE=\"\$HOSTSTATE\$\" -field HOSTOUTPUT=\"\$HOSTOUTPUT\$\" -field NOTIFICATIONTYPE=\"\$NOTIFICATIONTYPE\$\"",
  }

}
