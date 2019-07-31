#
# # Hiera config example:
# nagios::plugin::nrpe_website_string::item_list:
#   - url: 'google.com'
#     string: 'google'
#     warn_limit_s: '2'
#     crit_limit_s: '5'
#     timeout: '10'
#   - url: 'duckduckgo.com'
#     string: 'search'
#     warn_limit_s: '1'
#     crit_limit_s: '3'
#     timeout: '10'
#
# By default check connects via SSL!
#
# To be able to pass arguments to NRPE you need to modify nrpe.cfg setting 'dont_blame_nrpe=1'
#################################################################################################

class nagios::plugin::nrpe_website_string(
  Integer $notification_interval = $nagios::params::notification_interval,
  $item_list                     = [
                                    { url          => 'google.com',
                                      string       => 'google',
                                      warn_limit_s => '3',
                                      crit_limit_s => '5',
                                      timeout      => '10'
                                    },
                                  ],
){


# NRPE Command
  nrpe::command { 'check_http':
    ensure  => present,
    command => 'check_http -H $ARG1$ -s $ARG2$ -w "$ARG3$" -c "$ARG4$" -t "$ARG5$" -S';
  }

# Nagios Check
  $item_list.each | $item | {
    $command = "check_nrpe!check_http -a ${item[url]} ${item[string]} ${item[warn_limit_s]} ${item[crit_limit_s]} ${item[timeout]}"

    @@nagios_service {"Website_string ${item[string]} on ${item[url]} from ${::hostname}":
      check_command       => $command,
      service_description => "Website_string ${item[string]} on ${item[url]}",
      host_name           => $::fqdn,
      notify              => Service['nagios'],
      tag                 => pick($nagios::tag, $::environment),
      require             => Class['nagios'],
    }
  }
}
