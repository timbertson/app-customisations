function __rerun_last_line
	commandline -r ""
	and commandline -f history-search-backward execute
end

function fish_user_key_bindings -d "My key bindings for fish"
	# fish_default_key_bindings -M insert
	# fish_vi_key_bindings --no-erase

	bind --erase ctrl-r
	bind --erase f5
	bind ctrl-r __rerun_last_line
	bind f5 __rerun_last_line
	bind --user ctrl-up history-token-search-backward
	bind --user ctrl-down history-token-search-forward


	# # custom VI bindings:
	# bind --user -m default H backward-word
	# bind --user -m default L forward-word

end
