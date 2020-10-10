function __rerun_last_line
	commandline -r ""
	and commandline -f history-search-backward execute
end

function fish_user_key_bindings -d "My key bindings for fish"
	# Execute this once per mode that emacs bindings should be used in
	fish_default_key_bindings -M insert
	# Without an argument, fish_vi_key_bindings will default to
	# resetting all bindings.
	# The argument specifies the initial mode (insert, "default" or visual).
	fish_vi_key_bindings --no-erase

	# because of https://github.com/fish-shell/fish-shell/issues/1668
	bind --erase \cr
	bind --erase -k f5
	bind \cr __rerun_last_line
	bind -k f5 __rerun_last_line
	bind --user \e'[1;5A' history-token-search-backward # ctrl-up
	bind --user \e'[1;5B' history-token-search-forward # ctrl-down


	# custom VI bindings:
	bind --user -m default H backward-word
	bind --user -m default L forward-word

end
