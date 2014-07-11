function join
	set sep $argv[1]
	set cnt (count $argv)
	if test $cnt -gt 1
		echo -ns $argv[2]
	end
	if test $cnt -gt 2
		for elem in $argv[3..-1]
			echo -ns $sep$elem
		end
	end
	true
end
