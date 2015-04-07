function with-notify
	env $argv
	set st $status
	#echo "stat: $st"
	if [ $st = 0 ]
		set text "ok"
	else
		set text "FAILED"
	end
	#echo notify-send --expire-time=2 --app-name="Command $text" "$argv"
	notify-send --expire-time=2 --app-name=with-notify "Command $text:" "$argv"
	return $st
end
