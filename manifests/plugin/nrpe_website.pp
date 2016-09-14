#Called with the following command:
#check_command check_website_response!"http://www.domain.com/index.html"!1000!2000 
#This script will work on POSIX systems has been tested with the Dash shell in Linux Debian and Nagios core 3.2.1
#To use the --no-check-certificate option configure as follows:
#command_line $USER1$/check_website_response.sh -u $ARG1$ -w $ARG2$ -c $ARG3$ $ARG4$
#check_command check_website_response!"http://www.domain.com/index.html"!3000!4000!-nocert
#bash check_website_response.sh -w 2000 -c 5000 -u "https://security.education.govt.nz"

class nagios::plugin::nrpe_website(
  $warn = 2000,
  $crit = 5000,
  $weburl
){

  package {'netcat':
    ensure => 'present',
  }

  nrpe::plugin { 'check_website_response':
      ensure => present,
      source => 'puppet:///modules/nagios/check_website_response',
      notify => Service['nrpe'],
  }

# NRPE Command
  nrpe::command { 'check_website_response':
    ensure  => present,
    command => "check_website_response -w ${warn} -c ${crit}";
  }

# Nagios Check
  @@nagios_service {"Check Site $::hostname $weburl":
    check_command => "check_nrpe!\"check_website_response -u $weburl\"",
    service_description => "Response from $weburl",
    host_name => $::fqdn,
  }
}
