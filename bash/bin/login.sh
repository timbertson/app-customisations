#!/bin/sh

base=`dirname "$0"`
synergys
"$base/postip.rb"
gksudo "$base/write_hosts.rb"

nohup mumbles &

