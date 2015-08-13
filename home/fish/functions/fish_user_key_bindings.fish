function fish_user_key_bindings -d "My key bindings for fish"
	bind --erase \cg
	bind \cg complete_with_gsel

	# because of https://github.com/fish-shell/fish-shell/issues/1668
	bind --erase \cr
	bind --erase -k f5
	set refresh 'commandline -r ""; and commandline -f "execute" "history-search-backward"'
	bind \cr $refresh
	bind -k f5 $refresh
	#bind \t complete-until
end
