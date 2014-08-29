require "spec_helper"

describe interface("eth1") do
  it { should have_ipv4_address("205.144.162.131")}
end
