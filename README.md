----
    scpr-externalnet
----

This cookbook configures the external network interface on SCPR VMware 
virtual machines.  It sets up the external IP and creates an iptables 
firewall to limit the traffic that is allowed to come in over it.

To use the cookbook, add `recipe[scpr-externalnet]` to your run list. 

By default, the cookbook will do nothing.

To enable an external IP address, you will need to set the 
`scpr_externalnet.ip` attribute on the node.  It should be set to the 
IP address that you want the VM to have externally.

By default, all incoming traffic is blocked on the external interface.

To allow services to be externally accessible, you will need to set 
the `scpr_externalnet.tcp_ports` and `scpr_externalnet.udp_ports` 
attributes on the node or on a role.  Both take an array of port 
numbers on which incoming traffic should be accepted.

