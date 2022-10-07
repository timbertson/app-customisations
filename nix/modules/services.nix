{ pkgs, config, lib, ... }:
with lib;
with import ../session-vars.nix;
let
	# libglEnv = ["LD_LIBRARY_PATH=${pkgs.libGLU}/lib"];
	desktopSession = ["desktop-session.target"];
	systemPath = [ "/usr/local" "/usr" "/" ];
	userPath = systemPath ++ (map builtins.toString [
		home
		../../.
		../local/home-path
	]);
	nixPath = "NIX_PATH=${home}/.nix-defexpr/channels";
	pathEnv = dirs: ["PATH=\"${lib.concatMapStringsSep ":" (p: "${p}/bin") dirs}\""];
	remocaml = pkgs.remocaml or null;
	remocamlExists = remocaml != null;
	writeScript = contents:
		# write a script, then return its path for ExecStart
		let drv = pkgs.writeScript "script" ''#!${pkgs.bash}/bin/bash
			${contents}
		'';
		in "${drv}";

in {
	services.syncthing.enable = true;

	systemd.user = {
		targets."desktop-session".Unit = {}; # must exist for others to be wanted by it

		services.xbindkeys = {
			Install.WantedBy = desktopSession;
			Service = {
				Environment = pathEnv systemPath;
				ExecStart = writeScript "${loadSessionVars}; exec ${pkgs.xbindkeys}/bin/xbindkeys --nodaemon";
				Restart = "on-abnormal";
				RestartSec = "2";
			};
		};

		services.parcellite = {
			Install.WantedBy = desktopSession;
			Service = {
				ExecStart = writeScript "${loadSessionVars}; exec ${pkgs.parcellite}/bin/parcellite";
			};
		};

		services.album-releases.Service = {
			ExecStart = "${pkgs.status-check}/bin/status-check -f ${home}/.cache/album-releases.status --run ${pkgs.gup}/bin/gup ${home}/dev/web/album-releases/all";
			Restart="no";
			Environment = [
				"PYTHONUNBUFFERED=1"
				nixPath
			] ++ pathEnv (userPath ++ [pkgs.google-cloud-sdk]);
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
				ExecStart = "${remocaml}/bin/remocaml";
				Environment = [
					"REMOCAML_EPHEMERAL=60"
				];
			};
		};
		sockets.web-remote = mkIf remocamlExists {
			Install.WantedBy = [ "default.target" "sockets.target"];
			Socket.ListenStream = [ "8076" ];
		};

		services.irank = {
			Service = {
				Restart = "always";
				ExecStart = "${home}/dev/rust/irank-rs/target/release/irank-rs serve";
				Environment = [
					"IRANK_TLS_CREDENTIALS=${home}/.cache/tinybrick"
					"IRANK_TLS_DOMAIN=pew.gfxmonk.net"
					"IRANK_EPHEMERAL=60"
				];
			};
		};
		sockets.irank = {
			Install.WantedBy = [ "default.target" "sockets.target"];
			Socket.ListenStream = [ "8079" ];
		};

		# services.reset-mouse = {
		# 	Install.WantedBy = desktopSession;
		# 	Service = {
		# 		ExecStart = writeScript "${loadSessionVars}; exec reset-mouse";
		# 		Restart="no";
		# 		Environment = pathEnv userPath;
		# 	};
		# };

		services.xremap = {
			Install.WantedBy = [ "default.target" ];
			Service = {
				Restart = "always";
				ExecStart = "${home}/dev/oss/xremap/target/release/xremap --mouse ${home}/dev/app-customisations/home/xremap.yml";
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

	xdg.configFile."systemd/system/modprobe-uinput.service".text = ''
		# workaround for https://github.com/chrippa/ds4drv/issues/93
		[Service]
		ExecStart=modprobe uinput
		Restart=no
	'';

	xdg.configFile."systemd/system/modprobe-uinput.timer".text = ''
		[Install]
		WantedBy=multi-user.target

		[Timer]
		OnBootSec=20sec
	'';
}
