#
# # Hiera config example:
# nagios::plugin::nrpe_website_string::item_list:
#   - url: 'google.com'
#     uri: '/'
#     string: 'google'
#     warn_limit_s: '2'
#     crit_limit_s: '5'
#     timeout: '10'
#     onredirect: 'follow'
#     service_description: 'Website_string google on google.com'
#   - url: 'duckduckgo.com'
#     uri: '/'
#     string: 'search'
#     warn_limit_s: '1'
#     crit_limit_s: '3'
#     timeout: '10'
#     onredirect: 'follow'
#     service_description: 'Website_string search on duckduckgo.com'
#
# By default check connects via SSL and follows redirects.
#
# To be able to pass arguments to NRPE you need to modify nrpe.cfg setting 'dont_blame_nrpe=1'
#################################################################################################

class nagios::plugin::nrpe_website_string(
  Integer $notification_interval = lookup('nagios::notification_interval'),
  String $notification_period    = lookup('nagios::notification_period'),
  $item_list = [
    { url                 => 'google.com',
      uri                 => '/',
      string              => 'google',
      warn_limit_s        => '3',
      crit_limit_s        => '5',
      timeout             => '10',
      onredirect          => 'follow',
      service_description => 'Website_string google on google.com',
    },
  ],
){
  # Configure nrpe directories first
  include nrpe


# NRPE Command
  nrpe::command { 'check_http':
    ensure  => present,
    command => 'check_http -H $ARG1$ -u "$ARG2$" -s $ARG3$ -w "$ARG4$" -c "$ARG5$" -t "$ARG6$" -f "$ARG7$" -S';
  }

# Nagios Check
  $item_list.each | $item | {
    $command = "check_nrpe!check_http -a ${item[url]} ${item[uri]} ${item[string]} ${item[warn_limit_s]} ${item[crit_limit_s]} ${item[timeout]} ${item[onredirect]}"

    @@nagios_service {"Website_string ${item[string]} on ${item[url]} from ${::hostname}":
      check_command         => $command,
      service_description   => $item[service_description],
      host_name             => $::fqdn,
      notify                => Service['nagios'],
      tag                   => $::environment,
      notification_interval => $notification_interval,
      notification_period   => $notification_period,
      require               => Class['nagios'],
    }
  }
}
