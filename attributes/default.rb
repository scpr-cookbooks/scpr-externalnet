default.scpr_externalnet.ip         = nil
default.scpr_externalnet.tcp_ports  = []
default.scpr_externalnet.udp_ports  = []

default.scpr_externalnet.interface  = "eth1"

default.scpr_externalnet.subnets["205.144.162.128/27"] = {
  gateway:    "205.144.162.129",
  netmask:    "255.255.255.224",
  broadcast:  "205.144.162.159",
}

default.scpr_externalnet.subnets["205.144.162.160/27"] = {
  gateway:    "205.144.168.161",
  netmask:    "255.255.255.224",
  broadcast:  "205.144.168.191",
}

default.scpr_externalnet.accept_interfaces = ["lo","eth0"]
