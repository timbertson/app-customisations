function d
	set MANIFEST $HOME/dev/.projects
	set needs_build 1
	if not test -e $MANIFEST
		gup -qu $MANIFEST
		set needs_build 0
	end

	# can't use a subshell due to https://github.com/fish-shell/fish-shell/issues/1949
	# set dest (cat ~/dev/.projects | gsel-client)
	# cat ~/dev/.projects | gsel-client --null | read --local dest --null
	set dest (cat ~/dev/.projects | fzf)

	if test $status -eq 0
		cd ~/dev/$dest
	end
	if test $needs_build = 1
		gup -qu $MANIFEST &
	end
end

