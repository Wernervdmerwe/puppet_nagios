# Export Nagios service for check_tcp
#
#Usage:
#check_tcp -H host -p port [-w <warning time>] [-c <critical time>] [-s <send string>]
#[-e <expect string>] [-q <quit string>][-m <maximum bytes>] [-d <delay>]
#[-t <timeout seconds>] [-r <refuse state>] [-M <mismatch state>] [-v] [-4|-6] [-j]
#[-D <warn days cert expire>[,<crit days cert expire>]] [-S <use SSL>] [-E]
#[-N <server name indication>]
#/usr/lib64/nagios/plugins/check_tcp -H first.moe.govt.nz -p 9560 -w 2000 -c 4000
#
# # Hiera config example:
# nagios::plugin::nrpe_tcpcheck::item_list:
#   - url: 'google.com'
#     port: '443'
# 	  warn_limit_ms: '2000'
# 	  crit_limit_ms: '5000'
#   - url: 'google.com'
#     port: '80'
# 	  warn_limit_ms: '1000'
# 	  crit_limit_ms: '3000'
#
#
# To be able to pass arguments to NRPE you need to modify nrpe.cfg setting 'dont_blame_nrpe=1'
#################################################################################################
class nagios::plugin::nrpe_tcpcheck(
  $item_list                     = [{ url => 'google.com', port => '443', warn_limit_ms => '2000', crit_limit_ms => '5000' },],
  Integer $notification_interval = lookup('nagios::notification_interval')
){
  # Configure nrpe directories first
  include nrpe

  # NRPE Command
  nrpe::command { 'check_tcp-port_response':
    ensure  => present,
    command => 'check_tcp -H $ARG1$ -p $ARG2$ -w "$ARG3$" -c "$ARG4$"';
  }

  # Nagios Check
  $item_list.each | $item | {
    $command = "check_nrpe!check_tcp-port_response -a ${item[url]} ${item[port]} ${item[warn_limit_ms]} ${item[crit_limit_ms]}"

    @@nagios_service {"Check ${item[url]}:${item[port]} from ${::hostname}":
      check_command         => $command,
      service_description   => "Response from ${item[url]}:${item[port]}",
      host_name             => $::fqdn,
      notify                => Service['nagios'],
      tag                   => $::environment,
      notification_interval => $notification_interval,
      require               => Class['nagios'],
    }
  }
}
