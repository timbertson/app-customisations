function d
	set MANIFEST $HOME/dev/.projects
	if test -e $MANIFEST
	# keep up to date, but don't wait
		gup -qu $MANIFEST &
	else
		gup -qu $MANIFEST
	end

	# can't use a subshell due to https://github.com/fish-shell/fish-shell/issues/1949
	# set dest (cat ~/dev/.projects | gsel-client)
	# cat ~/dev/.projects | gsel-client --null | read --local dest --null
	set dest (cat ~/dev/.projects | fzf)

	if test $status -eq 0
		cd ~/dev/$dest
	end
end

