{ pkgs, config, lib, ... }:
with lib;
with import ../session-vars.nix;
let
	optional = x: attrs: if (x == null || x == false) then {} else attrs;
	displayEnv = ["DISPLAY=:1"]; # ugh...
	libglEnv = ["LD_LIBRARY_PATH=${pkgs.libGLU}/lib"];
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

	# TODO port legacy-unit-files over to home-manager compatible definitions
	legacy-unit-files = pkgs.callPackage ../make-systemd-units.nix {
		units =
			let
				sessionTask = x: {wantedBy = desktopSession; } // x;
			in
			lib.fold lib.recursiveUpdate {

				# services.tilda = sessionTask {
				# 	path = userPath;
				# 	# script = "${loadSessionVars}; ${pkgs.tilda}/bin/tilda";
				# 	#XXX tilda kills all X11 input devices on `sudo` if run via systemd.
				# 	# So I'm just using a tilda.desktop app on autostart instead
				# 	script = "${loadSessionVars}; /usr/bin/tilda";
				# 	serviceConfig = {
				# 		Environment = displayEnv ++ [
				# 			"TERM_SOLARIZED=1"
				# 			# "XDG_DATA_DIRS=${home}/.local/nix/share:/usr/local/share/:/usr/share/"
				# 			# "SSH_AUTH_SOCK=%t/keyring/ssh"
				# 		];
				# 	};
				# };

				# TODO: replace with home-manager stuff
				timers.daglink = {
					wantedBy = [ "default.target" "timers.target" ];
					timerConfig = {
						OnStartupSec = "10s";
					};
				};
				services.daglink = {
					path = userPath;
					serviceConfig = {
						ExecStart = "${pkgs.daglink}/bin/daglink -f";
					};
				};

				# TODO: replace with home-manager stuff
				timers.dconf-user-overrides = {
					wantedBy = [ "default.target" "timers.target" ];
					timerConfig = {
						OnStartupSec = "0s";
					};
				};
				services.dconf-user-overrides = {
					path = userPath;
					serviceConfig = {
						ExecStart = "${pkgs.dconf-user-overrides}/bin/dconf-user-overrides";
						Environment = [
							# "XDG_DATA_DIRS=/usr/local/share/:/usr/share/:${pkgs.shellshape}/share/gnome-shell/extensions/shellshape@gfxmonk.net/data"
							"GIO_EXTRA_MODULES=${pkgs.gnome3.dconf.lib}/lib/gio/modules"
						];
					};
				};
			} [

				# (let remocaml = "${home}/dev/web/remocaml"; in optional (builtins.pathExists remocaml) {
				# 	services.web-remote = {
				# 		# needed for `session-vars`
				# 		path = userPath;
				# 		serviceConfig = {
				# 			KillMode = "process";
				# 			Restart = "always";
				# 			ExecStart = "${remocaml}/_build/install/default/bin/remocaml";
				# 			Environment = [
				# 				"REMOCAML_EPHEMERAL=60"
				# 			];
				# 		};
				# 	};
				# 	sockets.web-remote = {
				# 		listenStreams = [ "8076" ];
				# 		wantedBy = [ "default.target" "sockets.target"];
				# 	};
				# })
			];
	};
in {
	# home.packages = [ legacy-unit-files ];

	systemd.user = {
		services.xbindkeys = {
			Install.WantedBy = desktopSession;
			Service = {
				Environment = pathEnv systemPath ++ displayEnv;
				ExecStart = writeScript "${loadSessionVars}; ${pkgs.xbindkeys}/bin/xbindkeys --nodaemon";
				Restart = "on-abnormal";
				RestartSec = "2";
			};
		};

		services.parcellite = {
			Install.WantedBy = desktopSession;
			Service = {
				Environment = displayEnv;
				ExecStart = writeScript "${loadSessionVars}; ${pkgs.parcellite}/bin/parcellite";
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

		# NOTE: borg.* must be copied to /etc/systemd/system
		# by gup target root/systemd/all
		services.borg = {
			Service = {
				ExecStart = "${home}/.local/nix/bin/my-borg-task";
				Restart="no";
			};
		};
		timers.borg = {
			Install.WantedBy = [ "multi-user.target" ];
			Timer = {
				OnStartupSec = "5min";
				Persistent = true;
			};
		};
	};
}
