#!/bin/sh

cat `dirname "$0"`/packages | xargs sudo apt-get install
