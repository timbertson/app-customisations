#!/bin/bash
if [ "$#" != '1' ] || [ ! -d "$1" ]; then
	base=/etc/profile.d/net.gfxmonk
	# echo "error: please specify the directory containing this file (bash_profile) as its first argument"
else
	base="$1"
fi

export PATH="$PATH:/sbin:/usr/sbin"

# colours
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`
LIGHT=`tput setaf 9`
GREY=`tput setaf 0`
PS1='\n\[$GREY\][\T] \[$YELLOW\]\u\[$GREY\]@\[$RED\]\h \[$BLUE\]\w/\[$GREEN\] \$\[$LIGHT\] '

function title
{
  export PROMPT_COMMAND='echo -ne "\033]0;'"$@"'\007"'
}

if [ `uname` == 'Darwin' ]; then
	source "$base/osx"
else
	source "$base/linux"
fi

source "$base/scm"
source "$base/alias"

# case insensitive file globbing (primaily for tab completion)
shopt -s nocaseglob

function cdbase {
	d=`dirname "$1"`
	cd "$d"
}

function ssh-setup 
{
  if [ $(( ${SSH_AGENT_PID} + 1)) == 1 ]; then
    eval `ssh-agent`
  fi
}

alias tmpdir="date +'%Y-%m-%d.%H-%M-%S'"
function cdtmp {
	t=/tmp/`tmpdir`
	mkdir -p "$t" && pushd "$t"
}

function timestamp {
	while read line; do
		t=`date "+%Y-%m-%d %H:%M:%S"`
		echo "$t: $line"
	done
}
