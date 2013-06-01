function fish_prompt --description 'Write out the prompt'
	set -l __exit_status $status
	printf "\n"
	if [ $__exit_status != 0 ]
		printf (set_color black)"[$__exit_status]\n"
	end
	if [ -n "$ZEROENV_NAME" ]
		printf (set_color blue)"[$ZEROENV_NAME] "
	end
	printf (set_color green)(whoami)
	printf (set_color (set -q SSH_CLIENT; and echo 'red'; or echo 'yellow'))
	printf @(hostname|cut -d . -f 1)
	printf ' '
	printf (set_color cyan)$PWD' '
	printf (set_color green)'$ '
	printf (set_color normal)
end
