module Iw
  module List
    def self.get(interface)
      [
        ["frequency", /Current Frequency:\s?([\.\d]+)\s+(\w+)\s+\(Channel\s?(\d{1,2})/], 
        ["channel", /Current Frequency:\s?([\.\d]+)\s+(\w+)\s+\(Channel\s?(\d{1,2})/], 
        ["bitrate", /Current Bit Rate=(\d+)\s+([\w\/]+)/], 
        ["rate", ""], 
        ["encryption", ""], 
        ["keys", ""], 
        ["power", /Current\smode:(\w+)/], 
        ["txpower", /Current Tx-Power=(\d+)\s+(\w+)\s+\((\d+)\s+(\w+)\)/], 
        ["retry", ""], 
        ["ap", ""], 
        ["accesspoints", ""], 
        ["peers", ""], 
        ["event", /([\da-fA-F]x[\da-fA-F]{4})\s+:\s+(.*)/], 
        ["auth", ""], 
        ["wpakeys", ""], 
        ["genie", ""], 
        ["modulation", ""]
      ]
    end
    
    def self.command(interface, option)
      
    end
  end
end