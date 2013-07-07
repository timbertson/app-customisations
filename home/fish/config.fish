set NODE_ROOT /usr/lib/nodejs
if [ -d /usr/local/share/npm ]
	set NODE_ROOT /usr/local/share/npm
end

set additional_paths \
	/sbin/ \
	/opt/ocaml/opam/bin \
	~/.opam/system/bin \
	~/.cabal/bin \
	$NODE_ROOT/bin \
	~/bin \
	~/.bin

set NODE_PATH $NODE_PATH $NODE_ROOT/lib/node_modules

if not contains ~/.bin/overrides $PATH
	set -x PATH ~/.bin/overrides $PATH
end
for p in $additional_paths
	if not contains $p $PATH
		set -x PATH $PATH $p
	end
end

set FISH_CLIPBOARD_CMD "cat" # Stop that.
set BROWSER firefox
set -x EDITOR vim
set -x force_s3tc_enable true # games often need this

# --------------
# OPAM:
set -x CAML_LD_LIBRARY_PATH /home/tim/.opam/system/lib/stublibs /usr/lib64/ocaml/stublibs
set -x OCAML_TOPLEVEL_PATH /home/tim/.opam/system/lib/toplevel
# --------------

# --------------
# turbo ZI aliases
#set zi_apps ~/.config/0install.net/apps/
#set zi_ocaml ~/dev/0install/zeroinstall/ocaml/_build/main.native
#if [ -f $zi_ocaml ]
#	for name in ack 0install
#		if not functions -q $name
#			if [ -f $zi_apps/$name/selections.xml ]
#				eval "function $name --description=\"$name ZeroInstall alias\"; $zi_ocaml run $name \$argv; end"
#			end
#		end
#	end
#end
# --------------

if [ -r ~/.aliasrc ]
	. ~/.aliasrc
end
alias ghost="sudo (which --skip-alias ghost)"
