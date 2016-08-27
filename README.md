Hieradata can look like this:

---
classes:
  - nagios::plugin::notify

## NRPE ##
nrpe::dont_blame_nrpe: 0
nrpe::allowed_hosts:
  - '127.0.0.1'
  - '192.168.50.202'

## Nagios ##
# Contacts
nagios::contacts:
  Werner:
    contact_name: 'werner'
    alias: 'Werner vd Merwe'
    ensure: 'present'
    email: 'wernervdmerwe@gmail.com'

# Hostgroups
nagios::hostgroups:
  Linux:
    alias: 'Linux Servers'
  test-servers:
    alias: 'Test Servers'

nagios_hostgroup: 'test-servers'

nagios::plugin::nrpe_core_load::warn: 4
nagios::plugin::nrpe_core_load::crit: 8

