set NODE_ROOT /usr/lib/nodejs
if [ -d /usr/local/share/npm ]
	set NODE_ROOT /usr/local/share/npm
end

set additional_paths \
	/sbin/ \
	~/.cabal/bin \
	$NODE_ROOT/bin \
	~/bin \
	~/.bin

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
# set -x CAML_LD_LIBRARY_PATH /home/tim/.opam/system/lib/stublibs /usr/lib64/ocaml/stublibs
# set -x OCAML_TOPLEVEL_PATH /home/tim/.opam/system/lib/toplevel
##IN PATH:
##/opt/ocaml/opam/bin \
##~/.opam/system/bin \
# --------------

if [ -f ~/dev/0install/zi-stable/share/fish/install-local.fish ]
	. ~/dev/0install/zi-stable/share/fish/install-local.fish
end

# --------------
# Workaround for fish $CWD bug on latest vte
# (https://github.com/fish-shell/fish-shell/issues/906)
if begin set -q VTE_VERSION; and test $VTE_VERSION -ge 3405; end
	function __update_vte_cwd --on-variable PWD --description 'Notify VTE of change to $PWD'
		status --is-command-substitution; and return
		perl -MURI::Escape -MEnv -e 'print "\033]7;file://" . uri_escape($PWD, "^a-za-z0-9\-\._~\/") . "\a"'
	end
end
# --------------

if [ -r ~/.aliasrc ]
	. ~/.aliasrc
end
