function fish_user_key_bindings -d "My key bindings for fish"
	# because of https://github.com/fish-shell/fish-shell/issues/1668
	#echo "XXX setting up my key bindings"

	bind --erase \cr
	bind --erase -k f5
	set refresh 'commandline -r ""; and commandline -f "execute" "history-search-backward"'
	bind \cr $refresh
	bind -k f5 $refresh
	bind \t complete-until

	## up
	#bind --erase \e\[A
	#bind --erase -k up
	#bind --erase \cp
	#bind \e\[A up-line
	#bind \cp up-line
	#bind -k up up-line

	## down
	#bind --erase \e\[B
	#bind --erase -k down
	#bind --erase \cm
	#bind \e\[B down-line
	#bind \cm down-line
	#bind -k down down-line


	#bind --erase -k ppage
	#bind --erase -k npage
	#bind -k ppage history-search-backward
	#bind -k npage history-search-forward
end
