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
set fish_complete_list 0

# --------------
# OPAM:
# set -x CAML_LD_LIBRARY_PATH /home/tim/.opam/system/lib/stublibs /usr/lib64/ocaml/stublibs
# set -x OCAML_TOPLEVEL_PATH /home/tim/.opam/system/lib/toplevel
##IN PATH:
##/opt/ocaml/opam/bin \
##~/.opam/system/bin \
# --------------

set ZI_0COMPILE ~/dev/0install/zi-ocaml/zeroinstall-ocaml.0compile/zeroinstall-ocaml-linux-x86_64
if [ -e $ZI_0COMPILE ]
	set bin $ZI_0COMPILE/files
	if not contains $bin $PATH
		#echo "adding PATH"
		set -x PATH $bin $PATH
	end

	set compl $ZI_0COMPILE/files/share/completions
	if not contains $compl $fish_complete_path
		# echo "adding fish_complete_path"
		# echo "$fish_complete_path"
		set -x fish_complete_path $fish_complete_path $compl
	end
end
	
# --------------
# Workaround for fish $CWD bug on latest vte
# (https://github.com/fish-shell/fish-shell/issues/906)
#if begin set -q VTE_VERSION; and test $VTE_VERSION -ge 3405; end
#	function __fish_urlencode --description "URL-encode stdin"
#		while read f
#			set lines (echo "$f" | sed -E -e 's/./\n\\0/g;/^$/d;s/\n//')
#			if [ (count $lines) -gt 0 ]
#				printf '%%%02x' "'"$lines"'" | sed -e 's/%2[fF]/\//g';
#			end
#		end
#		echo
#	end
#
#	function __update_vte_cwd --on-variable PWD --description 'Notify VTE of change to $PWD'
#		status --is-command-substitution; and return
#		printf '\033]7;file://%s\a' (pwd | __fish_urlencode)
#		#printf '\033]7;file://'; printf '%%%02x' "'"(pwd | sed -E -e 's/./\n\\0/g;/^$/d;s/\n//')"'" | sed -e 's/%2[fF]/\//g'; printf '\a'
#		#perl -MURI::Escape -MEnv -e 'print "\033]7;file://" . uri_escape($PWD, "^a-za-z0-9\-\._~\/") . "\a"'
#	end
#end
# --------------

if [ -r ~/.aliasrc ]
	. ~/.aliasrc
end
