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
	~/.local/nix/bin \
	~/.nix-profile/bin \
	~/.cargo/bin
	;

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
	~/bin \
	;

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
if test -f ~/.local/nix/share/fish/nix-caenv.fish
	.        ~/.local/nix/share/fish/nix-caenv.fish
end

# Nope.
for var in LESSPIPE LESSOPEN LESSCLOSE
	set -e -g $var
end
set -x BROWSER firefox
set -x EDITOR nvim
if test -n "$NVIM_LISTEN_ADDRESS"
	set -x EDITOR "nvr -cc split --remote-wait +'set bufhidden=wipe'"
end
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

set -x FZF_DEFAULT_OPTS '--color=spinner:-1,info:8 --height=50% --min-height 5 --reverse'

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
	status-check --desc "album releases" --max-age "30 days" ~/.cache/album-releases.status
	status-check --desc "borg backup" --max-age "2 days" ~/.cache/my-borg/backup
	and status-check --desc "borg remote sync" --max-age "5 days" ~/.cache/my-borg/sync
	and status-check --desc "borg integrity check" --max-age "4 days" ~/.cache/my-borg/check
end

set -x CONDUIT_TLS native # https://github.com/ocaml/opam-publish/issues/58
set -x PASSE_SERVER https://passe.gfxmonk.net/

if begin set -q TERM_PROGRAM ; and test $TERM_PROGRAM = 'iTerm.app'; end
	set iterm_dir_color_exe (which iterm-dir-color)
	if test -n $iterm_dir_color_exe
		function __set_tab_color_iterm2 --on-variable PWD --description 'Set item2 color'
			if status --is-command-substitution
				return
			end
			$iterm_dir_color_exe
		end
		$iterm_dir_color_exe
	end
end

# Emulates vim's cursor shape behavior
# set fish_cursor_default block
# set fish_cursor_insert line
# set fish_cursor_replace_one underscore
