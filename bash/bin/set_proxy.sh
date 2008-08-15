#!/bin/bash
if [[ "$0" =~ "set_proxy.sh" ]]
then
  echo "You must run this script via 'source $0' not directly"
  exit -1
fi

TIMEOUT=10
# have to blank out variables in case this is run more than once
USER_NAME=
PASSWORD=

read -t $TIMEOUT -p "Enter your username (w number) :" USER_NAME
echo
if [ -z "$USER_NAME" ]
then
  echo "Username not given within $TIMEOUT seconds - aborting"
  return
fi
read -t $TIMEOUT -s -p "Enter your password :" PASSWORD
echo

if [ -z "$PASSWORD" ]
then
  echo "Password not given within $TIMEOUT seconds - aborting"
  return
fi

# urlencode password, for people who put weird characters in them:
PASSWORD=`ruby -e'require "cgi"; puts CGI.escape("'"$PASSWORD"'")'`

export HTTP_PROXY=http://${USER_NAME}:${PASSWORD}@sensis-proxy.sensis.com.au:8080
export http_proxy=http://${USER_NAME}:${PASSWORD}@sensis-proxy.sensis.com.au:8080
