function fish_prompt --description 'Write out the prompt'
	#printf '$ '
	set -l __exit_status $status
	printf "\n"
	if [ $__exit_status != 0 ]
		printf '%s[%s]\n' (set_color black) $__exit_status
	end
	if [ -n "$ZEROENV_NAME" ]
		printf '%s[%s] ' (set_color blue) $ZEROENV_NAME
	end
	printf '%s%s' (set_color green) (whoami)
	printf '%s' (set_color (set -q SSH_CLIENT; and echo 'red'; or echo 'yellow'))
	printf '%s' @(hostname|cut -d . -f 1)
	printf ' '
	printf '%s%s ' (set_color cyan) $PWD
	printf '%s$ ' (set_color green)
	printf '%s' (set_color normal)
end
