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
&nbsp;&nbsp;class { 'nagios':  
&nbsp;&nbsp;&nbsp;&nbsp;role             => 'server',  
&nbsp;&nbsp;&nbsp;&nbsp;graphios_install => true,  
&nbsp;&nbsp;&nbsp;&nbsp;graphite_host    => $graphite_host  
&nbsp;&nbsp;}  
}

### Client
node client {  
&nbsp;&nbsp;include nagios  
}  

Hieradata
---------

Extra plugins can be added in hiera as follows:  

nagios_plugins:  
&nbsp;&nbsp;- nagios::plugin::notify  

This will include the notify plugin on this host.

### Hostgroups
Hostgroups have two steps, first create all the hostgroups in quetion:  
nagios::hostgroups:  
&nbsp;&nbsp;Linux:  
&nbsp;&nbsp;&nbsp;&nbsp;alias: 'Linux Servers'  
&nbsp;&nbsp;admin-prod:  
&nbsp;&nbsp;&nbsp;&nbsp;alias: 'Admin Servers - Production'  

Then add the servers into the groups by adding a lookup in the node:  
nagios_hostgroup: 'admin-prod'

This will add the host to both the Linux and Production Admin hostgroups.

### NRPE 
nrpe::dont_blame_nrpe: 0  
nrpe::allowed_hosts:  
&nbsp;&nbsp;- '127.0.0.1'  
&nbsp;&nbsp;- '192.168.0.1'  

### Contacts
nagios::contacts:  
&nbsp;&nbsp;nagiosadmin:  
&nbsp;&nbsp;&nbsp;&nbsp;contact_name: nagiosadmin  
&nbsp;&nbsp;&nbsp;&nbsp;alias: 'Nagios Admin'  
&nbsp;&nbsp;&nbsp;&nbsp;ensure: 'present'  
&nbsp;&nbsp;&nbsp;&nbsp;email: nagiosadmin@example.com  

### Override defaults
nagios::plugin::nrpe_core_load::warn: 4  
nagios::plugin::nrpe_core_load::crit: 8

Credits
-------
This is a collection of modules written by their respective owners.  
All credit goes to the respective authors
