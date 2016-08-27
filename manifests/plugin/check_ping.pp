class nagios::plugin::check_ping (
  $warn = 20,
  $crit = 60
){

# Nagios Check
  @@nagios_service { "check_ping_${::hostname}":
    check_command       => "check_ping!100.0,${warn}%!500.0,${crit}%",
    service_description => 'PING',
  }
}
