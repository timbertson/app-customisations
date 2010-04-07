#!/bin/bash
if [ "$#" != '1' ] || [ ! -d "$1" ]; then
	base=/etc/profile.d/net.gfxmonk
	# echo "error: please specify the directory containing this file (bash_profile) as its first argument"
else
	base="$1"
fi

export PATH="$PATH:/sbin:/usr/sbin"

# only run for bash
[ -z "$PS1" -o -z "$BASH" ] && return

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
source "$base/bashrc"
source "$base/completion"
source "$base/alias"
source "$base/prompt"

# case insensitive file globbing (primaily for tab completion)
shopt -s nocaseglob

function cdbase {
	d=`dirname "$1"`
	cd "$d"
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
