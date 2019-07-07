#
# # Hiera config example:
# nagios::plugin::nrpe_website::item_list:
#   - url: 'http://google.com'
# 	  warn_limit_ms: '2000'
# 	  crit_limit_ms: '5000'
#   - url: 'http://duckduckgo.com'
# 	  warn_limit_ms: '1000'
# 	  crit_limit_ms: '3000'
#
# To be able to pass arguments to NRPE you need to modify nrpe.cfg setting 'dont_blame_nrpe=1'
#################################################################################################

class nagios::plugin::nrpe_website(
  $item_list = [{ url => 'http://google.com', warn_limit_ms => '2000', crit_limit_ms => '5000' },],
){

  nrpe::plugin { 'check_website_response':
      ensure => present,
      source => 'puppet:///modules/nagios/check_website_response',
      notify => Service['nrpe'],
  }

# NRPE Command
  nrpe::command { 'check_website_response':
    ensure  => present,
    command => 'check_website_response -u $ARG1$ -w $ARG2$ -c "$ARG3$" -nocert';
  }

# Nagios Check
  $item_list.each | $item | {
    $command = "check_nrpe!check_website_response -a ${item[url]} ${item[warn_limit_ms]} ${item[crit_limit_ms]}"

    @@nagios_service {"Check site response ${::hostname} ${item[url]}":
      check_command       => $command,
      service_description => "Response from ${item[url]}",
      host_name           => $::fqdn,
      use                 => 'generic-service',
      tag                 => $nagios::tag,
    }
  }
}
