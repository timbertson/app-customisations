#!/bin/bash
# only run for interactive terms
[ -z "$PS1" ] && return
[ -n "$BASH" -o -n "$ZSH_VERSION" ] || return

if [ "$#" != '1' ] || [ ! -d "$1" ]; then
	base=/etc/profile.d/net.gfxmonk
	# echo "error: please specify the directory containing this file (net.gfxmonk.profile.sh) as its first argument"
else
	base="$1"
fi

export PATH="$PATH:/sbin:/usr/sbin"

function title
{
  export PROMPT_COMMAND='echo -ne "\033]0;'"$@"'\007"'
}

if [ $(uname) = 'Darwin' ]; then
	source "$base/osx"
else
	source "$base/linux"
fi

function set_terminal_title {
	echo -ne "\033]0;$(echo "$(basename "${PWD}") ($(dirname "${PWD}"))" | sed -e "s@${HOME}@~@")\007"
}

source "$base/scm"
source "$base/path"
if [ -n "$BASH" ]; then
	source "$base/bashrc"
	source "$base/bash_completion"
	source "$base/bash_prompt"
fi
if [ -n "$ZSH_VERSION" ]; then
	source "$base/zshrc"
	source "$base/zsh_completion"
	source "$base/zsh_prompt"
fi
source "$base/alias"
source "$base/completion"

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
