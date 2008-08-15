#!/usr/bin/env ruby
require 'net/http'
OLD_FAKEDNS_URL="http://maven.sensis.com.au:4567/hosts"
FAKEDNS_URL="http://maven.sensis.com.au:45678/hosts/"
# note - don't try to detect platform, it's too tricky - instead use the existence of
#  hosts files.  Not sure how this works under cygwin...
CANDIDATE_HOSTS = ['C:\\WINDOWS\\system32\\drivers\\etc\\hosts','/etc/hosts']
HOSTS_PREFIX = "# --- FAKEDNS START"
HOSTS_HEADER = <<EOF
# --- following data written by fakedns hostswriter - will be overwritten on re-writing
# Note that any hosts you define outside this block will not be overwritten - they
# will be commented out in this block.
EOF
HOSTS_SUFFIX = "# --- FAKEDNS END"

def append_old_hostsdata(fake_hosts, found_hostnames)
  output = HOSTS_HEADER.split("\n")
  fake_hosts.each do |line|
    case
      when line =~ /^\s*#/
        output << line
      when line =~ /^\s*([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\s+(.*)$/
        hostnames = $2.split(/\s+/)
        if hostnames.size > 1
          raise "writer can't handle multiple host names for an ip in fakedns yet. Line is:#{line}"
        end
        if found_hostnames.include? hostnames[0]
          puts "commenting out existing host #{hostnames[0]}"
          output << "#" + line
        else
          output << line
        end
    else
      output << line
    end
  end
  output
end

hosts_file = CANDIDATE_HOSTS.detect{ |h| File.exists?(h)}

raise "Can't find a valid hosts file in #{CANDIDATE_HOSTS.inspect}" unless hosts_file
raise "Can't write to #{hosts_file}" unless File.writable?(hosts_file)

fake_hosts = []
if ARGV.size == 0
  puts "No namespace - using old server.  WARNING: this is deprecated, will go away some day soon!"
  response = Net::HTTP.get_response(URI.parse(OLD_FAKEDNS_URL))
  case response
  when Net::HTTPSuccess
    fake_hosts << response.body.split("\n")
  else
    raise "Invalid response from #{FAKEDNS_URL}: #{response}"
  end
else
  ARGV.each do |arg|
    puts "trying namespace #{arg}"
    response = Net::HTTP.get_response(URI.parse(FAKEDNS_URL + arg))
    case response
    when Net::HTTPSuccess
      fake_hosts << response.body.split("\n")
    else
      raise "Invalid response from #{FAKEDNS_URL}: #{response}"
    end
  end
end


old_hosts = nil
File.open(hosts_file, "r") { |f| old_hosts = f.readlines }

new_hosts = []
found_hostnames = []
in_old_fakehosts = false
had_old_fakehosts = false
had_end_token = false
old_hosts.each do |line|
  line.chomp!
  case
  when line == HOSTS_PREFIX
    in_old_fakehosts = true
    had_old_fakehosts = true
    new_hosts << line
  when line == HOSTS_SUFFIX
    had_end_token = true
    in_old_fakehosts = false
    new_hosts << append_old_hostsdata(fake_hosts,found_hostnames)
    new_hosts << line
  when line =~ /^\s*#/
    next if in_old_fakehosts
    new_hosts << line
  when line =~ /^\s*([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\s+(.*)$/
    next if in_old_fakehosts
    found_hostnames += $2.split(/\s+/)
    new_hosts << line
  else
    new_hosts << line unless in_old_fakehosts
  end
end
raise "start hosts token found but no end token - please clean up #{hosts_file}" if had_old_fakehosts && !had_end_token

unless had_old_fakehosts
  new_hosts << HOSTS_PREFIX
  new_hosts << append_old_hostsdata(fake_hosts, found_hostnames)
  new_hosts << HOSTS_SUFFIX
end

tempfile = hosts_file + ".tmp_" + Time.now.strftime("%Y%m%d_%H%M%S")
raise "Can't create temp file - file #{tempfile} already exists!" if File.exists?(tempfile)
backupfile = hosts_file + ".bak_" + Time.now.strftime("%Y%m%d_%H%M%S")
raise "Can't back up - backup file #{backupfile} already exists!" if File.exists?(backupfile)
File.open(tempfile,"w") do |f|
  new_hosts.each { |line| f.puts line }
end
begin
  File.rename(hosts_file,backupfile)
rescue ex
  puts "Failed to rename hosts file '#{hosts_file}' to backup '#{backupfile}' - hosts unchanged, temp data in '#{tempfile}'"
  raise ex
end  
begin
  File.rename(tempfile,hosts_file)
rescue ex
  puts "Failed to rename temp file '#{tempfile}' to '#{hosts_file}' - hosts may be broken! Original is in '#{backupfile}' - restore by hand!!!"
  raise ex
end  
 
puts "Complete.  Hosts file #{hosts_file} updated - previous hosts data is in '#{backupfile}'"
