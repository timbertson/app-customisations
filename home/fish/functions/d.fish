function d
	set MANIFEST $HOME/dev/.projects
	set needs_build 1
	if not test -e $MANIFEST
		gup -qu $MANIFEST
		set needs_build 0
	end
	set dest (cat ~/dev/.projects | gsel-client)
	if test needs_build = 1
		gup -qu $MANIFEST &
	end
	if test $status -eq 0
		cd ~/dev/$dest
	end
end

