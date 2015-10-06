function d
	set MANIFEST $HOME/dev/.projects
	gup -qu $MANIFEST
	set dest (cat ~/dev/.projects | gsel-client)
	if test $status -eq 0
		cd ~/dev/$dest
	end
end

