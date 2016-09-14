#Called with the following command:
#check_command check_website_response!"http://www.domain.com/index.html"!1000!2000 
#This script will work on POSIX systems has been tested with the Dash shell in Linux Debian and Nagios core 3.2.1
#To use the --no-check-certificate option configure as follows:
#command_line $USER1$/check_website_response.sh -u $ARG1$ -w $ARG2$ -c $ARG3$ $ARG4$
#check_command check_website_response!"http://www.domain.com/index.html"!3000!4000!-nocert


class nagios::plugin::nrpe_website(
  $warn = 2000,
  $crit = 5000,
  $site
){

# NRPE Command
  nrpe::command { 'check_website_response':
    ensure  => present,
    command => "check_website_response.sh -w ${warn} -c ${crit}";
  }

# Nagios Check
  @@nagios_service {"Check Site $::hostname $site":
    check_command => "check_nrpe!check_website_response -u $site",
    service_description => "Response from $site",
  }
}