#Usage:
#check_tcp -H host -p port [-w <warning time>] [-c <critical time>] [-s <send string>]
#[-e <expect string>] [-q <quit string>][-m <maximum bytes>] [-d <delay>]
#[-t <timeout seconds>] [-r <refuse state>] [-M <mismatch state>] [-v] [-4|-6] [-j]
#[-D <warn days cert expire>[,<crit days cert expire>]] [-S <use SSL>] [-E]
#[-N <server name indication>]
#/usr/lib64/nagios/plugins/check_tcp -H first.moe.govt.nz -p 9560 -w 2000 -c 4000
#
### url_and_port_list example ###
#      $url_and_port_list = [
#          { url => 'google.com', port => '443', warn_limit_ms => '2000', crit_limit_ms => '5000' },
#          { url => 'google.com', port => '80', warn_limit_ms => '1000', crit_limit_ms => '2000' },
#      ]
#################################
class nagios::plugin::nrpe_tcpcheck(
  $item_list = [{ url => 'google.com', port => '443', warn_limit_ms => '2000', crit_limit_ms => '5000' },],
){

# Nagios Check
  $item_list.each | $item | {
    @@nagios_service {"Check ${item[url]}:${item[port]} from ${::hostname}":
      check_command       => "check_nrpe!check_tcp  -H \"${item[url]}\" -p ${item[port]} -w ${item[warn_limit_ms]} -c ${item[crit_limit_ms]}",
      service_description => "Response from ${item[url]}:${item[port]}",
      target              => "/etc/nagios/conf.d/${::fqdn}.cfg",
      host_name           => $::fqdn,
      use                 => 'generic-service',
    }
  }
}
