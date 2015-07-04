function complete_with_gsel
	set arg (commandline --current-token)
	# echo "INITIAL: $arg" >> /tmp/fish-gsel-log
	if test -z $arg
		return
	end

	# remove trailing slash
	set arg (echo $arg | sed -e "s!/\$!!")

	# XXX can't get fish to expand ~ in a string, so hack it up:
	set base (echo $arg | sed -e "s!^~/!$HOME/!")
	if not test -d $base
		set arg (dirname $arg)
		set base (dirname $base)
	end
	#echo "BASE: $base" >> /tmp/fish-gsel-log

	set dest (indir $base find-bfs ^/dev/null | sed -e 's!^\./!!' | gsel-client)
	if test $status -eq 0
		# echo "COMPLETED: $dest" >> /tmp/fish-gsel-log
		commandline --current-token $arg/$dest
	end
end

