require "spec_helper"

describe interface("eth1") do
  it { should have_ipv4_address("205.144.162.131")}
end

describe file("/etc/iproute2/rt_tables") do
  its(:content) { should include("scpr-ext") }
end

describe command("ip route show table scpr-ext") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should include("dev eth1")}
end

describe command("ip rule show") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should include("lookup scpr-ext") }
end