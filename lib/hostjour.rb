$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'ghost'
require 'dnssd'

module Hostjour
  Host = Struct.new(:hostname, :ip, :identifier)
  
  @hosts = []
  
  VERSION = '0.0.1'
  
  SERVICE = "_hostjour._tcp"
  
  def self.list
    servers = {}
    service = DNSSD.browse(SERVICE) do |reply|
      servers[reply.name.chomp] ||= reply
    end
    STDERR.puts "Searching for servers (1 second)"
    # Wait for something to happen
    sleep 5
    service.stop
    puts "servers found: #{servers.size}"
    servers.each do |string,obj|
      DNSSD.resolve(obj.name, obj.type, obj.domain) do |rr|
        puts rr.methods(false)
      end
    end
  end
  
  def self.advertise(identifier = ENV["USER"])
    tr = DNSSD::TextRecord.new
    tr["version"] = VERSION
    tr["identifier"] = identifier
    tr["primary_ip"] = get_ip
    tr["hostnames"] = []
    
    ::Host.list.each do |host|
      if host.ip == '127.0.0.1' || host.ip == get_ip
        tr["hostnames"] << host.hostname
      end
    end
    
    tr["hostnames"] = tr["hostnames"].join(',')
    
    name = `hostname`.gsub('.local','') || tr["identifier"]
    
    # Some random port for now
    DNSSD.register(name, SERVICE, "local", 9682, tr.encode) do |reply|
    end
  end
  
  def self.get_ip
    # Hard code to airport for now
    @ip ||= `ifconfig en1`.match(/inet ((?:\d{1,3}\.){3}\d{1,3})/)[1]
  rescue
    '0.0.0.0'
  end
end

# Hostjour.advertise
# sleep