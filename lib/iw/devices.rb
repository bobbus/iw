require 'yaml'

module Iw
  # Iw a wireless tool wrapper library
  #
  # Copyright (c) 2010 Thomas Gallaway
  #
  # == Examples
  #
  # === Get all wireless interfaces
  #
  #  require 'iw'
  #  i = Iw::Devices.new
  #  puts i.interfaces.inspect
  #
  class Devices

    attr_reader :interfaces, :physical

    def initialize(options={})
      @options    = options
      @options[:test] = @options[:test] ||= false
      @physical   = {}
      @interfaces = {}
      update
    end
    
    def list
      @interfaces.keys
    end
    
    def config(i)
      @interfaces[i][:config] = Config.new(i) if @interfaces.keys.include?(i)
    end
    
    def cmd(option)
      @options[:test] ? File.read(
        File.join(LIBPATH, "test", "files", "iw_#{option.gsub(' ', '_')}.txt") ) : `iw #{option}`
    end

    def update
      physical_regexp = Regexp.compile(/\s*phy\#(\d{1,2})\s*Interface\s([\w\d]+)\s*ifindex\s(\d{1,2})\s+type\s(\w+)/)
      physical_interface = Proc.new{|x| { :name => x[1], :index => x[2].to_i, :mode => x[3] } }      
      interface_proc = Proc.new{|a| { 
        :physical => a[0], :index => a[0], :mode => a[0], :frequencies => {}, :bitrates => [] } }
      
      frequency_regexp = Regexp.compile(/(\d+)\s+(\w+)\s+\[(\d+)\]\s+\(([\d\.]+)\s+(\w+)\)\s*\(?([^).]*)\)?/)
      frequency_proc   = Proc.new{|a| { 
        :frequency => a[0].to_i, :frequency_range => a[1], 
        :power => a[2].to_f, :power_range => a[3], :info => a[4] } }
        
      bitrates_regexp  = Regexp.compile(/([\d\.]+)\s+(\w+)\s*\(?([^).]*)\)?/)
      bitrates_proc    = Proc.new{|a| { :bitrate => a[0].to_i, :bitrate_range => a[1], :info => a[2] } }
      
      # Maps the physical interfaces to the linux names
      cmd('dev').scan(physical_regexp).each do |physical| 
        @physical["phy#{physical[0]}"] = physical_interface.call(physical)
      end
      
      # Gets all the interfaces and it's configurations
      iw = cmd('list').gsub( "\t", "    " ).gsub( "*", "-" ).gsub( "#", "num")
      
      iw.scan( /Wiphy\sphy\d+/ ).each do |interface| 
        iw = iw.gsub( interface, ":#{interface.to_node}:" )
      end
      
      items = iw.scan( /\s+(.*)\:/ ).map{ |x| x.first }.each do |item| 
        iw = iw.gsub( item, ":#{item.to_node}" )
      end

      # hack to make it easier to read the output
      interfaces = YAML.load( "---\n" + iw )

      # Here's the mapping & cleaning of the values
      interfaces.each_pair do |name, interface|
        # Get's the actually physical name
        phy = name.to_s.split("_")[1]
        # Set's the interface name for the hash
        name = @physical[phy][:name]

        #Initial mapping of some values
        @interfaces[name] = interface_proc.call( [ phy, @physical[phy][:index], @physical[phy][:mode] ] )
        
        interface.each_pair do |key, values|

          if values.class == Hash
            values.each_pair do |if_k, if_v|
              case if_k.to_s
              when "frequencies" then
                @interfaces[name][:frequencies][$3.to_i] = if_v.map do |x|
                  x =~ frequency_regexp
                  frequency_proc.call( $1, $2, $4, $5, $6 )
                end
              when "bitrates" then
                @interfaces[name][:bitrates] = if_v.map do |x|
                  x =~ bitrates_regexp
                  bitrates_proc.call($1, $2, $3)
                end
              else
                @interfaces[name][if_k.to_sym] = if_v
              end
            end
          else
            @interfaces[name][key.to_sym] = values
          end
        end
      end
    end
  end
end
