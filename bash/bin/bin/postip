#!/usr/bin/env ruby
require 'net/http'
FAKEDNS_URL="http://wiki.sensis.com.au:4567/"
INTERFACE=PLATFORM =~ /darwin/ ? "en0" : "eth0"
IFCONFIG_CMD="/sbin/ifconfig"
HOSTNAME_CMD="hostname"

force = false
if ARGV.size > 0
  if ARGV[0] == "-force"
    force = true
  else
    raise "Invalid command line arguments - only valid argument currently is \"-force\" to overwrite address if mac has changed."
  end
end

if RUBY_PLATFORM =~ /cygwin|mswin|win32/
  puts "Windows mode...."
  IFCONFIG_CMD = "ipconfig /all"
  INTERFACE="IP Address"
  
  hostname = `#{HOSTNAME_CMD}`.strip
  ifinfo = `#{IFCONFIG_CMD}`
  if ifinfo !~ /Physical Address.*([0-9A-Fa-f-]{17})/
    raise "no mac address in ifinfo:\n" + ifinfo
  end
  mac = $1.gsub('-',':')
  if ifinfo !~ /IP Address.*(161\.117\.[0-9]+\.[0-9]+)/  
    raise "no ip address in ifinfo:\n" + ifinfo
  end
  ip = $1
else
  # *nix (hopefully)
  hostname = `#{HOSTNAME_CMD}`.strip
  ifinfo = `#{IFCONFIG_CMD} #{INTERFACE}`
  if ifinfo !~ /(HWaddr|ether)\s+([0-9A-Za-z:]+)/
    raise "no mac address in ifinfo:\n" + ifinfo
  end
  mac = $2
  if ifinfo !~ /inet\s+(addr:)?([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
    raise "no ip address in ifinfo:\n" + ifinfo
  end
  ip = $2
end


params = {'mac' => mac, 'name' => hostname, 'ip' => ip}
params['force'] = 'yes' if force
puts "FakeDNS: posting host '#{hostname}' ip '#{ip}' at mac '#{mac}' to server at #{FAKEDNS_URL}"
puts " - forcing overwrite of old mac address" if force
res = Net::HTTP.post_form(URI.parse(FAKEDNS_URL),  params)
case res
when Net::HTTPSuccess
  puts "Posted OK."
else
  puts "Posting IP address failed:"
  puts res.body
end
