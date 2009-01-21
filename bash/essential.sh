#!/bin/sh
# essential functionality in a single file; for easy deployment to new boxes
# usage:
# curl <location> > /tmp/bashrc && . /tmp/bashrc

# common and obvious aliases
alias ll='ls -l'
alias la='ls -la'

alias grep='egrep --color'
alias less='less -R' # raw character support (ie colours)

# other names for things
alias ad='pushd' # "add dir"
alias sd='popd'  # "subtract dir"
alias pbcopy='xsel -ib' # that's what it's called on a mac ;)
alias pbpaste='xsel -ob'

# additional functionality
alias cwd='echo -n `pwd` | xsel -ib' # copy working dir to clipboard

# shorthand
alias ff='firefox'
alias open='gnome-open'
alias tm='gedit' # nothing like it, but I habitually use "tm" on linux


# i hate capslock with a passion...
xmodmap -e 'remove Lock = Caps_Lock'
xmodmap -e 'keysym Caps_Lock = Control_L'
xmodmap -e 'add Control = Control_L'


# ----------------------------
# functions
# ----------------------------

function color-diff
{
	# inline ruby? CLASSY!
	ruby -e '
	$stdin.each do |line|
	  puts( if line =~ /^\+(.*)$/
	        "\e[32m#{$&}\e[0m" 
	        elsif line =~ /^-(.*)$/
	          "\e[31m#{$&}\e[0m" 
	        elsif line =~ /^@(.*)$/
	          "\e[36m#{$&}\e[0m" 
	        elsif line =~ /^[^ \t](.*)$/
	          "\e[36m#{$&}\e[0m" 
	        else
	          line
	        end
	      )
	  end
'
}

# make subversion diff almost as awesome as git's:
function svn-diff
{
	svn diff $@ | color-diff
}

alias giff='git diff --color'

# alias 'g' to git. If no args supplied, do "git status"
function g
{
	if [ "$#" = '0' ]; then
		git status
	else
		git "$@"
	fi
}

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
# ooh! pretty colours :D
PS1='\n\[$GREY\][\T] \[$YELLOW\]\u\[$GREY\]@\[$RED\]\h \[$BLUE\]\w/\[$GREEN\] \$\[$LIGHT\] '

# cd to the dir containing "file"
function cdbase {
	d=`dirname "$1"`
	cd "$d"
}

