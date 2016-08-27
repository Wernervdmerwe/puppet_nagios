Nagios Module
=============

Hieradata
---------

classes:
  - nagios::plugin::notify

## NRPE ##
  nrpe::dont_blame_nrpe: 0
  nrpe::allowed_hosts:
    - '127.0.0.1'
    - %{ipaddr}

## Nagios ##
# Contacts
  nagios::contacts:
    Name:
      contact_name: short_name
      alias: Full Name
      ensure: 'present'
      email: me@home.right.now

# Hostgroups
  nagios::hostgroups:
    Linux:
      alias: 'Linux Servers'
    test-servers:
      alias: 'Test Servers'
  
  nagios_hostgroup: 'test-servers'

# Override defaults
  nagios::plugin::nrpe_core_load::warn: 4
  nagios::plugin::nrpe_core_load::crit: 8


