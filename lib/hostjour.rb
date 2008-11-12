$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'dnssd'

module Hostjour
  VERSION = '0.0.1'
  
  SERVICE = "_http._tcp"
  
  def self.list
    servers = {}
    service = DNSSD.browse(SERVICE) do |reply|
      servers[reply.name] ||= reply
    end
    STDERR.puts "Searching for servers (3 seconds)"
    # Wait for something to happen
    sleep 3
    service.stop
    servers.each { |string,obj|
      name, port = string.split ":" 
      STDERR.puts "Found web app called '#{name}'"
    }
  end
end

Hostjour.list