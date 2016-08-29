Nagios Module
=============

NOTE: This module was initially hard-coded as a quick stop-gap and I am only now in process of parameterising the module. This currently assumes a RHEL family O/S.

This module will manage server and client nodes.
It relies on exported resources to auto-add clients, thus requires puppetDB to be used.

The module also optionally installs and configures Graphios in order to send results to a Graphite server.

Standard checks deployed on all hosts:
- Load Per Core
- Swap Usage
- Logged On Users
- Disk Usage
- Zombie Processes
- Memory Usage
- Puppet Agent Status
- SSH
- PING

Usage
-----
### Server:
node nagios {  
    class { 'nagios':  
      role         => 'server',  
      graphite_host => $graphite_host  
  }  
}

### Client
node client {  
    include nagios  
}  

Hieradata
---------

Extra plugins can be added in hiera as follows:

nagios_plugins:  
  - nagios::plugin::notify

This will include the notify plugin on this host.

### Hostgroups
All Linux servers will be added to the Linux group. Extra groups can be added by using the following:

nagios_hostgroup: 'admin'

This will add the host to both the Linux and admin hostgroups.

### NRPE 
  nrpe::dont_blame_nrpe: 0  
  nrpe::allowed_hosts:  
    - '127.0.0.1'  
    - '192.168.0.1'  

### Contacts
  nagios::contacts:  
    nagiosadmin:  
      contact_name: nagiosadmin  
      alias: 'Nagios Admin'  
      ensure: 'present'  
      email: nagiosadmin@example.com  

### Override defaults
  nagios::plugin::nrpe_core_load::warn: 4  
  nagios::plugin::nrpe_core_load::crit: 8

Credits
-------
This is a collection of modules written by their respective owners.  
All credit goes to the respective authors
