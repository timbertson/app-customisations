#!/usr/bin/env ruby

[
  '/home/lab/.bashrc',
  '/home/lab/.bash_profile',
  '/home/lab/.vimrc',
  '/home/lab/bin/',
].each do |file|
  `scp -r '#{file}' 'lab@#{ARGV[-1]}:#{file}'`
end

