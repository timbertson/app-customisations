# set NODE_ROOT /usr/lib/nodejs
# if [ -d /usr/local/share/npm ]
# 	set NODE_ROOT /usr/local/share/npm
# end

# Nope.
for var in LESSPIPE LESSOPEN LESSCLOSE
	set -e -g $var
end

set additional_paths \
	/sbin/ \
	~/bin \
	~/.bin \
	~/.bin/zi \
	~/.nix-profile/bin


if test -f /etc/pki/tls/certs/ca-bundle.crt
	set -x GIT_SSL_CAINFO /etc/pki/tls/certs/ca-bundle.crt
	set -x CURL_CA_BUNDLE /etc/pki/tls/certs/ca-bundle.crt
end

set -x NIX_PATH ~/.nix-defexpr/channels

for p in $additional_paths
	if not contains $p $PATH
		# echo "append PATH $p"
		set -x PATH $PATH $p
	end
end

# NOTE: LAST path is most overridey
set path_overrides \
	~/.local/nix/bin \
	~/.bin/overrides

for p in $path_overrides
	if not contains $p $PATH
		#echo "prepend PATH $p"
		set -x PATH $p $PATH
	end
end


set additional_mans \
	~/.nix-profile/share/man \
	~/.local/nix/share/man
if not set -q MANPATH
	# default manpath. Not as extensive as /etc/man.conf; but prevents
	# dumb "man path is too long" when the default behaviour is to search $PATH
	set -x MANPATH /usr/man /usr/share/man /usr/local/share/man
end

for p in $additional_mans
	if not contains $p $MANPATH
		set -x MANPATH $MANPATH $p
	end
end


set FISH_CLIPBOARD_CMD "cat" # Stop that.
set BROWSER firefox
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

set extra_complete_paths \
	~/.local/nix/share/fish/completions \
	~/dev/ocaml/passe/share/fish/completions \
	/usr/share/fish/completions

for p in $extra_complete_paths
	if begin test -e $p; and not contains $p $PATH; end
		set fish_complete_path $fish_complete_path $p
	end
end

# completions paths from env:
# if set -q FISH_COMPLETE_PATH
# 	# echo "NOTE: adding $FISH_COMPLETE_PATH to $fish_complete_path"
# 	set fish_complete_path (echo $FISH_COMPLETE_PATH | tr ':' '\n') $fish_complete_path /usr/share/fish/completions
# end

if [ -r ~/.aliasrc ]
	. ~/.aliasrc
end

# XXX fish is supposed to remember these, but it fails quite a lot.
set fish_color_command d7ffff
set fish_color_param afd7ff
set fish_greeting ""
