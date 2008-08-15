#!/usr/bin/env ruby

[
  '.bashrc',
  '.bash_profile',
  '.vimrc',
  '/etc/exports',
  'bin/',
].each do |file|
  puts "transferring file: #{file}"
  `cd && scp -r "#{file}" "#{ARGV[-1]}:#{file}"`
end

