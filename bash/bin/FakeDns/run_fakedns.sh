#!/bin/bash
source ~/.profile
nohup jruby fakedns.rb -p 45678 -x 2>&1 > fakedns.log &
