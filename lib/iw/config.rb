module Iw
  # Iw::Config a wireless tool wrapper library
  # 
  # Copyright (c) 2010 Thomas Gallaway
  #
  # == Examples
  #
  # === Get Wireless Interface Status
  #
  #  require 'iw'
  #  interface = Iw::Config.new("wlan1")
  #  status = interface.status
  #  puts status
  #
  # === Disable the essid checking
  #
  #  require "iw"
  #  interface = Iw::Config.new("wlan1")
  #  interface.essid(:any)
  #    
  # === Enable the essid checking and setting it to "vaccuum"
  #
  #  require "iw"
  #  interface = Iw::Config.new("wlan1")
  #  interface.essid(true)
  #  interface.essid("vaccuum")
  #    
  # === Set the ESSID of the interface to "something"
  #
  #  require "iw"
  #  interface = Iw::Config.new("wlan1")
  #  interface.essid("something")
  #
  # === Set the ESSID of the interface to "ANY"
  #
  #  require "iw"
  #  interface = Iw::Config.new("wlan1")
  #  interface.essid("ANY")
  #
  class Config
    def initialize(interface)
      @interface = interface
    end

    # Sets the <tt>ESSID</tt> for the wireless interface or
    # allows to enable/disable verification of the <tt>ESSID</tt>.
    #
    # In addition to a string value these are the options that can
    # be set:
    # * true  - enables <tt>ESSID</tt> checking
    # * false - disables <tt>ESSID</tt> checking
    # * :any  - disables <tt>ESSID</tt> checking
    #
    def essid( value )
      value = case value.class.to_s
      when 'String' then 
        ["off", "on", "any", "OFF", "ON", "ANY"].include?( value ) ? "-- \"#{value}\"" : value
      when 'Symbol' then 
        value == :any ? "any" : value.to_s
      else
        stringval( value )
      end
      iwconfig("essid #{value}")
    end
    
    # Set's the operational mode of the device.
    #  Options: managed|ad-hoc|master|...
    #
    def mode( value )
      iwconfig("mode #{value}")      
    end
    
    # Set's the <tt>frequency</tt>
    #  N.NNN[k|M|G]
    #
    def freq( value )
    end
    
    # Set's the <tt>channel</tt>
    #  N
    #
    def channel( value )
    end
    
    # Set's the <tt>Bitrate</tt> of the device
    #  Options: N[k|M|G]|auto|fixed
    #    
    def bit( value )
    end
    
    # Set's the <tt>rate</tt>    
    #  Values: N[k|M|G]|auto|fixed
    #
    def rate( value )
    end
    
    # Set's the <tt>encryption</tt>
    #  Values: NNNN-NNNN|off
    #
    def enc( value )
    end
    
    # Set's the <tt>key</tt>
    #  Options: NNNN-NNNN|off
    #  Examples:
    #  * 0123-4567-89
    #  * [3] 0123-4567-89
    #  * s:password [2]
    #  * [2]
    #  * open
    #  * off
    #  * restricted [3] 0123456789
    #  * 01-23 key 45-67 [4] key [4]
    def key( value )
      iwconfig("key #{value}")      
    end
    
    # Set's the <tt>power</tt>
    #  Options: period N|timeout N|saving N|off
    #  Example:
    #  * period 2
    #  * 500m unicast
    #  * timeout 300u all
    #  * saving 3
    #  * off
    #  * min period 2 power max period 4
    #
    def power( value )
      iwconfig("power #{value}")
    end
    
    # Set's the <tt>nickname</tt>
    #  Options: NNN
    #
    def nickname( value ) 
    end
    
    # Set's the <tt>Network ID</tt>
    #  Options: NN|on|off
    def nwid( value )
    end
    
    # Set's the <tt>AP</tt>
    #  Options: N|off|auto
    #    
    def ap( value )
    end
    
    # Set's the <tt>AP</tt>
    #  Options: NmW|NdBm|off|auto
    #
    def txpower( value ) 
    end
    
    # Set's the <tt>AP</tt>
    #  Options: N
    #
    def sens( value )
    end
    
    # Set's the <tt>AP</tt>
    #  Options: limit N|lifetime N
    #
    def retry( value )
    end
    
    # Set's the <tt>rts</tt>
    #  Options: N|auto|fixed|off
    #
    def rts( value )
    end
    
    # Set's the <tt>rts</tt>
    #  Options: N|auto|fixed|off
    #
    def frag( value )
    end
    
    # Set's the <tt>modulation</tt>
    #  Options: 11g|11a|CCK|OFDMg|...
    #
    def modulation( value ) 
    end

    # Returns the current device <tt>status</tt>
    # 
    def status      
      output = iwconfig
      return {
        :retry_long_limit => output[/Retry\s+long\s+limit:(\d+)/, 1].to_i,
        :power_management => boolval(output[/Power\s+Management:(\w+)/, 1]),
        :essid => output[/ESSID:"(.*)"/, 1],
        :mode => output[/Mode:(\w+)/, 1],
        :frequency => output.scan(/Frequency:([\d\.]*)\s(\w{3})/).first,
        :access_point => output[/Access Point:\s([\d\:a-fA-F]*)/, 1],
        :bit_rate => output.scan(/Bit Rate=(\d+)\s([\w\/]+)/).first.map{|x| x =~ /\d+/ ? x.to_i : x},
        :tx_power => output.scan(/Tx-Power=(\d+)\s(\w+)/).first.map{|x| x =~ /\d+/ ? x.to_i : x},
        :rts_thr => boolval(output[/RTS\s+thr:(\w+)/, 1]),
        :fragment_thr => boolval(output[/Fragment\s+thr:(\w+)/, 1]),
        :link_quality => output.scan(/Link Quality=(\d{1,3})\/(\d{1,3})/).first.map{|x| x.to_i},
        :signal_level => output.scan(/Signal\s+level=([-\d]+)\s(\w+)/).first.map{|x| x =~ /\d+/ ? x.to_i : x},
        :rx_invalid_nwid => output[/Rx invalid nwid:(\d+)/, 1].to_i,
        :rx_invalid_crypt => output[/Rx invalid crypt:(\d+)/, 1].to_i,
        :rx_invalid_frag => output[/Rx invalid frag:(\d+)/, 1].to_i,
        :tx_excessive_retries => output[/Tx excessive retries:(\d+)/, 1].to_i,
        :invalid_misc => output[/Invalid misc:(\d+)/, 1].to_i,
        :missed_beacon => output[/Missed beacon:(\d+)/, 1].to_i
      }
    end
    
    private
    
    def iwconfig( values = "" )
      return `iwconfig #{@interface} #{values}`
    end
    
    def boolval( value )
      return value.downcase == "on" ? true : false
    end
    
    def stringval( value )
      if value.class == TrueClass
        return "on"
      elsif value.class == FalseClass
        return "off"
      else
        return value.to_s
      end
    end
        
  end
end