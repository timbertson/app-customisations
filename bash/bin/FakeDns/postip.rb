#!/usr/bin/env ruby
require 'net/http'
# old url for backward compatibility - should be removed once all clients moved
#  to new server (i.e. all clients specify a namespace)
OLD_FAKEDNS_URL="http://maven.sensis.com.au:4567/"
FAKEDNS_URL="http://maven.sensis.com.au:45678/"
INTERFACE=PLATFORM =~ /darwin/ ? "en0" : "eth0"
IFCONFIG_CMD="/sbin/ifconfig"
HOSTNAME_CMD="hostname"

# Note there are libraries for command line handling, but to keep this as light
#  as possible we will roll our own.
force = false
namespace = nil
ARGV.each do |arg|
  case arg
  when "-force"
    force = true
  when /-.*/
    raise "Invalid argument #{arg} - only valid arguments are a namespace, and \"-force\" to overwrite address if mac has changed"
  else
    raise "Can't specify two namespaces!" unless namespace.nil?
    namespace = arg
  end
end

if namespace.nil?
  puts "**** Warning - no namespace specified, working in backward-compatible mode - this may not work forever!"
else
  puts "Posting ip for namespace #{namespace}"
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
params['namespace'] = namespace if namespace
url = namespace ? FAKEDNS_URL : OLD_FAKEDNS_URL
puts "FakeDNS: posting host '#{hostname}' ip '#{ip}' at mac '#{mac}' with namespace '#{namespace}' to server at #{url}"

puts " - forcing overwrite of old mac address" if force
res = Net::HTTP.post_form(URI.parse(url),  params)
case res
when Net::HTTPSuccess
  puts "Posted OK."
else
  puts "Posting IP address failed:"
  puts res.body
end
