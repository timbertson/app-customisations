{ pkgs, config, lib, ... }:
with lib;
with import ../session-vars.nix;
let
	displayEnv = ["DISPLAY=:1"]; # ugh...
	# libglEnv = ["LD_LIBRARY_PATH=${pkgs.libGLU}/lib"];
	desktopSession = ["desktop-session.target"];
	systemPath = [ "/usr/local" "/usr" "/" ];
	userPath = systemPath ++ (map builtins.toString [
		home
		../../.
		../local
		../home/home-path
	]);
	pathEnv = dirs: ["PATH=\"${lib.concatMapStringsSep ":" (p: "${p}/bin") dirs}\""];
	remocaml = "${home}/dev/web/remocaml";
	remocamlExists = builtins.pathExists remocaml;
	writeScript = contents:
		# write a script, then return its path for ExecStart
		let drv = pkgs.writeScript "script" ''#!${pkgs.bash}/bin/bash
			${contents}
		'';
		in "${drv}";
in {
	systemd.user = {
		services.xbindkeys = {
			Install.WantedBy = desktopSession;
			Service = {
				Environment = pathEnv systemPath ++ displayEnv;
				ExecStart = writeScript "${loadSessionVars}; exec ${pkgs.xbindkeys}/bin/xbindkeys --nodaemon";
				Restart = "on-abnormal";
				RestartSec = "2";
			};
		};

		services.parcellite = {
			Install.WantedBy = desktopSession;
			Service = {
				Environment = displayEnv;
				ExecStart = writeScript "${loadSessionVars}; exec ${pkgs.parcellite}/bin/parcellite";
			};
		};

		services.album-releases.Service = {
			ExecStart = "${pkgs.status-check}/bin/status-check -f ${home}/.cache/album-releases.status --run ${pkgs.gup}/bin/gup ${home}/dev/web/album-releases/all";
			Restart="no";
			Environment = [ "PYTHONUNBUFFERED=1" ] ++ pathEnv (userPath ++ [pkgs.google-cloud-sdk]);
		};

		timers.album-releases = {
			Install.WantedBy = [ "default.target" "timers.target" ];
			Timer = {
				OnCalendar = "21:00:00";
				Persistent = true;
			};
		};

		services.web-remote = mkIf remocamlExists {
			Service = {
				KillMode = "process";
				Restart = "always";
				ExecStart = "${remocaml}/_build/install/default/bin/remocaml";
				Environment = [
					"REMOCAML_EPHEMERAL=60"
				];
			};
		};
		sockets.web-remote = mkIf remocamlExists {
			Install.WantedBy = [ "default.target" "sockets.target"];
			Socket.ListenStream = [ "8076" ];
		};

		services.tilda = {
			Service = {
				ExecStart = writeScript "${loadSessionVars}; exec ${pkgs.tilda}/bin/tilda";
				Environment = displayEnv ++ [
					"TERM_SOLARIZED=1"
					# "XDG_DATA_DIRS=${home}/.local/nix/share:/usr/local/share/:/usr/share/"
					# "SSH_AUTH_SOCK=%t/keyring/ssh"
				] ++ pathEnv userPath;
			};
		};
	};

	# NOTE: these have no effect on their own, they will be
	# copied to /etc/systemd/system by gup target root/systemd/all
	xdg.configFile."systemd/system/borg.service".text = ''
		[Service]
		ExecStart=${pkgs.my-borg-task}/bin/my-borg-task
		Restart=no
	'';
	xdg.configFile."systemd/system/borg.timer".text = ''
		[Install]
		WantedBy=multi-user.target

		[Timer]
		OnStartupSec=5min
		Persistent=true
	'';
}
