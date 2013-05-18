#!/bin/bash
# only run for interactive terms
[ -z "$PS1" ] && return
[ -n "$BASH" -o -n "$ZSH_VERSION" ] || return

if [ "$#" != '1' ] || [ ! -d "$1" ]; then
	base="$(readlink -f "$(dirname "$([ -n "${BASH_SOURCE[0]}" ] && echo "${BASH_SOURCE[0]}" || echo "$0")")")"
else
	base="$1"
fi
if [ ! -d "$base" ]; then
	echo "error: please specify the directory containing this file (net.gfxmonk.profile/) as its first argument"
	return
fi

export PATH="$PATH:/sbin:/usr/sbin"
export EDITOR=vim

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

source "$base/path"
if [ -n "$BASH" ]; then
	source "$base/bashrc"
	source "$base/bash_prompt"
	PROFILE_PATH="$PROFILE_PATH:$BASH_PROFILE_PATH"
fi
if [ -n "$ZSH_VERSION" ]; then
	source "$base/zshrc"
	source "$base/zsh_completion"
	source "$base/zsh_prompt"
	PROFILE_PATH="$PROFILE_PATH:$ZSH_PROFILE_PATH"
fi
echo "$PROFILE_PATH" | tr ':' '\n' | while read f; do
	if [ -f "$f" ]; then
		source "$f"
	fi
done

function cdbase {
	d=`dirname "$1"`
	cd "$d"
}

function maybesource {
	[ -r "$1" ] && . "$1"
}
maybesource ~/.pathrc
maybesource ~/.aliasrc

