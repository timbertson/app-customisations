#!/bin/bash
#docker attach!

set -eu

IMAGE_NAME="dev"
CONTAINER_NAME="dev"
CONTAINER_HOSTNAME="docker-dev"
VOLUME_NAME="dev-nix"
SSH_PORT="2022"
RUN_ARGS=(\
	--name "$CONTAINER_NAME" \
	--hostname "$CONTAINER_HOSTNAME" \
	--rm \
	--cap-add=SYS_PTRACE \
	-p "127.0.0.1:$SSH_PORT:$SSH_PORT" \
	--volume ~/docker/home:/home/tim \
	--volume /tmp/.X11-unix:/tmp/.X11-unix \
	--volume dev-nix:/nix
)
DETACH="--detach"

USER_SHELL="/home/tim/.local/nix/bin/fish"

function volume_exists() {
	docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1
}

function container_running() {
	if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
		msg="${1:-}"
		if [ -n "$msg" ]; then
			echo "$msg"
		fi
		return 0
	else
		return 1
	fi
}

function stop_container() {
	docker stop "$CONTAINER_NAME" > /dev/null
}

MODE="ssh"
SSH_ARGS=(-t)

for i in "$@"; do
	case "$i" in
		-x)
			set -x
			shift
		;;

		-X)
			SSH_ARGS+=(-X)
			shift
		;;

		--attach)
			MODE="attach"
			shift
		;;

		--root)
			RUN_ARGS+=(--user root)
			USER_SHELL="/bin/bash"
			shift
		;;

		--rebuild)
			docker build -t "$IMAGE_NAME" ~/dev/app-customisations/docker
			shift
		;;

		--failsafe)
			MODE="failsafe"
			shift
		;;

		--ssh)
			MODE="ssh"
			shift
		;;

		-f|--foreground)
			DETACH="-ti"
			shift
		;;

		-r|--restart)
			if container_running; then
				stop_container
			fi
			shift
		;;

		-s|--stop)
			stop_container
			exit 0
		;;

		#-s=*|--searchpath=*)
		#	SEARCHPATH="${i#*=}"
		#	shift # past argument=value
		#;;

		--delete-volume)
			docker volume rm dev-nix
			shift
		;;

		--)
			shift
			break
		;;

		-*)
			echo "Unknown option: $1"
			echo "Options:"
			echo "  -x|--ssh|--attach|-r/--restart|-s/--stop|-f/--foreground|--delete-volume|--failsafe"
			exit 1
		;;

		*)
			break
		;;
	esac
done

volume_exists || docker volume create -d local "$VOLUME_NAME"

if [ "$MODE" == "ssh" ]; then
	container_running || (
		echo "Starting new container"
		docker run "${RUN_ARGS[@]}" --user root $DETACH "$IMAGE_NAME" /home/tim/.nix-profile/bin/sshd \
			-p "$SSH_PORT" -f /home/tim/.ssh/sshd.conf -D \
			"$@"
		echo "SSH started on localhost:$SSH_PORT"
	)
	exec ssh "${SSH_ARGS[@]}" localhost -p "$SSH_PORT" "$USER_SHELL"
elif [ "$MODE" == "failsafe" ]; then
	exec docker run "${RUN_ARGS[@]}" -ti "$IMAGE_NAME" /bin/bash
elif [ "$MODE" == "attach" ]; then
	container_running || (
		echo "Starting new container"
		docker run "${RUN_ARGS[@]}" $DETACH "$IMAGE_NAME" /bin/bash -c 'while true; do sleep 9999; done'
	)
	exec docker exec -ti "$CONTAINER_NAME" "$USER_SHELL"
else
	echo "Unknown mode: $MODE"
	exit 1
fi

