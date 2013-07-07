function "!!"
	if [ (count $argv) -eq 0 ]
		set args "sudo"
	else
		set args $argv
	end
	echo "$args $history[1]"
	eval "$args $history[1]"
end
