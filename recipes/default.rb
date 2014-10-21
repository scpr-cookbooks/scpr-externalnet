# Goal: For a server that should be externally accessible, configure its
# second interface for a given public IP address and set up a firewall,
# allowing only the ports specified in the whitelist.

include_recipe "network_interfaces"

if node.scpr_externalnet.ip
  if node.scpr_externalnet.accept_interfaces.include?(node.scpr_externalnet.interface)
    raise "Cannot run scpr_externalnet with external interface in accept_interfaces."
  end

  # I was setting the 'block' attribute on all of the new nodes, but then
  # I got sick of doing that, so here we are. If you see a "block" attribute on
  # a node's externalnet config, you can remove it.
  block = node.scpr_externalnet.ip.match(/\A\d+\.\d+\.162\.\d+\z/) ? 1 : 2

  # write our up script
  template "/etc/network/scpr-ifup-#{ node.scpr_externalnet.interface }.sh" do
    action    :create
    source    "scpr-ifup.sh.erb"
    variables({
      interface:  node.scpr_externalnet.interface,
      ip:         node.scpr_externalnet.ip,
      gateway:    node['scpr_externalnet']["block#{block}"]['gateway'],
      localnet:   node['scpr_externalnet']["block#{block}"]['localnet'],
    })
    mode      0755
  end

  # enable the interface
  network_interfaces node.scpr_externalnet.interface do
    target    node['scpr_externalnet']['ip']
    gateway   node['scpr_externalnet']["block#{block}"]['gateway']
    broadcast node['scpr_externalnet']["block#{block}"]['broadcast']
    mask      node['scpr_externalnet']["block#{block}"]['netmask']
    post_up   "/etc/network/scpr-ifup-#{ node.scpr_externalnet.interface }.sh"
  end

  # set up iptables
  include_recipe "iptables-ng::install"

  iptables_ng_chain "FIREWALL" do
    policy "- [0:0]"
  end

  # send traffic to the firewall
  iptables_ng_rule "75-scpr_externalnet-firewall-input" do
    chain "INPUT"
    table "filter"
    rule "-j FIREWALL"
  end

  # allow all traffic from the internal interface
  iptables_ng_rule "80-scpr_externalnet-allow-internal" do
    chain "FIREWALL"
    table "filter"
    rule Array(node.scpr_externalnet.accept_interfaces).map { |iface| "-i #{iface} -j ACCEPT" }
  end

  # allow established traffic
  iptables_ng_rule "82-scpr_externalnet-established" do
    chain "FIREWALL"
    table "filter"
    rule "-m state --state ESTABLISHED,RELATED -j ACCEPT"
  end

  # set up TCP port allows
  iptables_ng_rule "83-scpr_externalnet-tcpports" do
    chain "FIREWALL"
    table "filter"
    rule Array(node.scpr_externalnet.tcp_ports).map { |p| "-m state --state NEW -m tcp -p tcp --dport #{p} -j ACCEPT" }
  end

  # set up UDP port allows
  iptables_ng_rule "83-scpr_externalnet-udpports" do
    chain "FIREWALL"
    table "filter"
    rule Array(node.scpr_externalnet.udp_ports).map { |p| "-m state --state NEW -m udp -p udp --dport #{p} -j ACCEPT" }
  end

  # Allow ICMP connections from SCPR subnet
  # This is necessary for load balancer health checks
  iptables_ng_rule "83-scpr_externalnet-icmp" do
    chain "FIREWALL"
    table "filter"
    rule "-p icmp -j ACCEPT"
  end

  # reject everything else
  iptables_ng_rule "84-scpr_externalnet-reject" do
    chain "FIREWALL"
    table "filter"
    rule "-j REJECT"
  end

else
  # make sure we're disabled?
  network_interfaces node.scpr_externalnet.interface do
    action :remove
  end

  template "/etc/network/scpr-ifup-#{ node.scpr_externalnet.interface }.sh" do
    action :remove
  end
end
