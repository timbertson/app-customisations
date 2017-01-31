# set NODE_ROOT /usr/lib/nodejs
# if [ -d /usr/local/share/npm ]
# 	set NODE_ROOT /usr/local/share/npm
# end

if not set -q MANPATH
	# default manpath. Not as extensive as /etc/man.conf; but prevents
	# dumb "man path is too long" when the default behaviour is to search $PATH
	set -x MANPATH /usr/man /usr/share/man /usr/local/share/man
end

set additional_paths \
	/sbin \
	~/.bin \
	~/bin \
	;

set -x NIX_BUILD_SHELL /bin/bash

for p in $additional_paths
	if not contains $p $PATH
		if test -e $p
			# echo "append PATH $p"
			set -x PATH $PATH $p
		end
	end
end

# NOTE: LAST path is most overridey
set path_overrides \
	~/.local/nix/bin \
	~/.nix-profile/bin

for p in $path_overrides
	if not contains $p $PATH
		if test -e $p
			#echo "prepend PATH $p"
			set -x PATH $p $PATH
		end
	end
end

set config_roots \
	~/.local/nix/share \
	~/dev/ocaml/passe/share \
	~/.nix-profile/share \
	/usr/share

for root in $config_roots
	if test -e $config_root
		# echo "# config_root: $root"
		set p $root/fish/completions
		if begin test -e $p; and not contains $p $fish_complete_path; end
			# echo "# + fish_complete_path: $p"
			set fish_complete_path $fish_complete_path $p
		end

		set p $root/fish/functions
		if begin test -e $p; and not contains $p $fish_function_path; end
			# echo "# + fish_function_path: $p"
			set fish_function_path $fish_function_path $p
		end

		set p $root/man
		if begin test -e $p; and not contains $p $MANPATH; end
			# echo "# + MANPATH: $p"
			set -x MANPATH $MANPATH $p
		end
	end
end


set -x NIX_PATH ~/.nix-defexpr/channels
# needed for nix-packaged utils
if test -f /etc/pki/tls/certs/ca-bundle.crt
	set -x GIT_SSL_CAINFO /etc/pki/tls/certs/ca-bundle.crt
	set -x CURL_CA_BUNDLE /etc/pki/tls/certs/ca-bundle.crt
	set -x SSL_CERT_FILE /etc/pki/tls/certs/ca-bundle.crt
end

# Nope.
for var in LESSPIPE LESSOPEN LESSCLOSE
	set -e -g $var
end
set FISH_CLIPBOARD_CMD "true" # Stop that.
set -x BROWSER firefox
set -x EDITOR vim
set -x force_s3tc_enable true # games often need this

set -x NOSE_PROGRESSIVE_EDITOR_SHORTCUT_TEMPLATE \
	'  {term.black}{editor} {term.cyan}+{term.bold}{line_number:<{line_number_max_width}} {term.blue}{path}{normal}{function_format}{term.yellow}{hash_if_function}{function}{normal}'
set -x NOSE_PROGRESSIVE_EDITOR 'gvimr'
set -x NOSE_PROGRESSIVE_ADVISORIES 1

# direnv
if isatty stdin; and which direnv >/dev/null 2>&1
	set -x DIRENV_LOG_FORMAT (set_color 777)" direnv: %s"(set_color reset)
	eval (direnv hook fish)
end

set -x GEM_HOME $HOME/.gem

if [ -r ~/.aliasrc ]
	. ~/.aliasrc
end

# XXX fish is supposed to remember these, but it fails quite a lot.
set fish_color_command d7ffff
set fish_color_param afd7ff
set fish_greeting ""

# add site-local config
if test -e $HOME/.config/fish/site.fish
	. $HOME/.config/fish/site.fish
end

complete -e -c g
complete -c g --wraps git

if begin isatty stderr; and not test -f ~/.config/status-check/IGNORE_THIS_MACHINE; end
	status-check --desc "borg backup" --max-age "2 days" ~/.cache/my-borg/backup
	and status-check --desc "borg remote sync" --max-age "5 days" ~/.cache/my-borg/sync
	and status-check --desc "borg integrity check" --max-age "4 days" ~/.cache/my-borg/check
end
