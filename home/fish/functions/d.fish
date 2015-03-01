function d
	set dest (indir ~/dev/ find -maxdepth 2 -type d | gsel)
	if test $status -eq 0
		cd ~/dev/$dest
	end
end

