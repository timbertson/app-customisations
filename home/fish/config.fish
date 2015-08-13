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
	~/.cabal/bin \
	$NODE_ROOT/bin \
	~/bin \
	~/.bin \
	~/.nix-profile/bin

# ~/.bin/nix/bin \
# set additional_mans \
# 	~/.bin/nix/share/man

set -x NIX_PATH ~/.nix-defexpr/channels

if not contains ~/.bin/overrides $PATH
	set -x PATH ~/.bin/overrides $PATH
end
for p in $additional_paths
	if not contains $p $PATH
		set -x PATH $PATH $p
	end
end

# NOTE: LAST path is most overridey
set path_overrides \
	~/.bin/nix/bin \
	~/.bin/overrides

for p in $path_overrides
	# echo "OVERR! $p"
	if not contains $p $PATH
		set -x PATH $p $PATH
	end
end


# for p in $additional_mans
# 	if not contains $p $MANPATH
# 		set -x MANPATH $MANPATH $p
# 	end
# end


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

# completions paths from env:
if set -q FISH_COMPLETE_PATH
	# echo "NOTE: adding $FISH_COMPLETE_PATH to $fish_complete_path"
	set fish_complete_path (echo $FISH_COMPLETE_PATH | tr ':' '\n') $fish_complete_path /usr/share/fish/completions
end

if [ -r ~/.aliasrc ]
	. ~/.aliasrc
end

# XXX fish is supposed to remember these, but it fails quite a lot.
set fish_color_command d7ffff
set fish_color_param afd7ff
set fish_greeting ""
