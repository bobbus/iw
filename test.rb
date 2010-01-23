require 'lib/iw'

def device_test
i = Iw::Devices.new
#puts i.inspect
puts i.list.inspect
wlan = i.config("wlan1")
puts wlan.status
end

def config_test
  a = Iw::Config.new("wlan1")
  puts a.status.inspect
end

config_test