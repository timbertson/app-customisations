function fish_prompt --description 'Write out the prompt'
	#printf '$ '
	set -l __exit_status $status
	if test $CMD_DURATION -gt 2000 -a -x /usr/bin/notify-send
		set __last_cmd (history search -n 1)
		if [ $__exit_status = 0 ]
			notify-send --hint=int:transient:1 --expire-time=2000 --app-name='fish' "Success: ($__last_cmd)" &
		else
			notify-send --hint=int:transient:1 --expire-time=2000 --app-name='fish' "Command failed ($__exit_status): $__last_cmd" &
		end
	end
	printf "\n"
	if [ $__exit_status != 0 ]
		printf '%s[%s]\n' (set_color black) $__exit_status
	end
	if [ -n "$ENV_NAME" ]
		printf '%s[%s] ' (set_color blue) $ENV_NAME
	end
	printf '%s%s' (set_color green) (whoami)
	printf '%s' (set_color (set -q SSH_CLIENT; and echo 'red'; or echo 'yellow'))
	printf '%s' @(hostname|cut -d . -f 1)
	printf ' '
	printf '%s%s ' (set_color cyan) $PWD
	printf '%s$ ' (set_color green)
	printf '%s' (set_color normal)
end
