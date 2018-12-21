{ config, lib, pkgs, utils, ... }:
let
	sd = import <nixpkgs/nixos/modules/system/boot/systemd-lib.nix> { inherit config lib pkgs; };
	optional = x: attrs: if (x == null || x == false) then {} else attrs;
	home = builtins.getEnv "HOME";
	displayEnv = ["DISPLAY=:1"]; # ugh...
	libglEnv = ["LD_LIBRARY_PATH=${pkgs.libGLU}/lib"];
	sessionTask = x: {wantedBy = ["desktop-session.target"]; } // x;
	systemPath = [ "/usr/local" "/usr" "/" ];
	loadSessionVars = "eval \"$(/home/tim/.bin/session-vars --all --process gnome-shell --export)\"";
	userPath = systemPath ++ [
		"${home}"
		"${home}/dev/app-customisations"
		"${home}/dev/app-customisations/nix/local"
	];
in
{
	config = {
		systemd.user = lib.fold lib.recursiveUpdate {
			# album releases cron job
			services.album-releases = {
				path = userPath;
				serviceConfig = {
					ExecStart = "${pkgs.gup}/bin/gup ${home}/dev/web/album-releases/all";
					Restart="no";
					Environment = [
						"PYTHONUNBUFFERED=1"
					];
				};
			};
			timers.album-releases = {
				wantedBy = [ "default.target" "timers.target" ];
				timerConfig = {
					OnCalendar = "21:00:00";
					Persistent = true;
				};
			};



			services.borg =
			# NOTE: must be copied to /etc/systemd/system
			# by gup target root/systemd/all
			let
				# exe = "${pkgs.my-borg}/bin/my-borg";
				exe = "${home}/.local/nix/bin/my-dev/python/my-borg/bin/my-borg";
			in
			{
				serviceConfig = {
					ExecStart = "${home}/.local/nix/bin/my-borg-task";
					Restart="no";
				};
			};
			timers.borg = {
				wantedBy = [ "multi-user.target" ];
				timerConfig = {
					OnStartupSec = "5min";
					Persistent = true;
				};
			};


			# usermode DNS alias
			sockets.dns-alias = {
				wantedBy = [ "default.target" "sockets.target"];
				socketConfig = {
					ListenDatagram = "127.0.0.1:5053";
				};
			};
			services.dns-alias = {
				serviceConfig = {
					ExecStart = "${pkgs.dns-alias}/bin/dns-alias --port 5053";
					Environment = "PYTHONUNBUFFERED=1";
					EnvironmentFile = "-%h/.config/dns-alias/env";
				};
			};

			services.xbindkeys = sessionTask {
				path = systemPath;
				serviceConfig = {
					ExecStart = "${pkgs.xbindkeys}/bin/xbindkeys --nodaemon";
					Environment = displayEnv;
					Restart = "on-abnormal";
					RestartSec = "2";
				};
			};

			services.dropbox = {
				serviceConfig = {
					ExecStart = "${home}/.dropbox-dist/dropboxd";
					Environment = displayEnv ++ libglEnv;
				};
			};

			services.parcellite = sessionTask {
				script = "${loadSessionVars}; ${pkgs.parcellite}/bin/parcellite";
				serviceConfig = {
					Environment = displayEnv;
				};
			};

			# services.guake = sessionTask {
			# 	path = userPath;
			# 	script = "${loadSessionVars}; ${pkgs.guake or "/usr"}/bin/guake";
			# 	serviceConfig = {
			# 		# ExecStart = "${pkgs.guake or "/usr"}/bin/guake";
			# 		Environment = displayEnv;
			# 	};
			# };

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

			services.rygel = {
				path = systemPath;
				serviceConfig = {
					ExecStart = "${pkgs.rygel or "/usr"}/bin/rygel";
				};
			};

			services.st = {
				serviceConfig = {
					Environment = ["STTRACE=connections,discover"];
					ExecStart = "${pkgs.syncthing}/bin/syncthing";
				};
			};

			# services.xflux = sessionTask {
			# 	serviceConfig = {
			# 		ExecStart = "${pkgs.xflux}/bin/xflux -l 37.7833 -g 144.9667 -k 4600 -nofork";
			# 		Environment = displayEnv;
			# 		# xflux goes nuts when input is /dev/null, probably a read loop somewhere.
			# 		# Just make it a socket which nobody talks to
			# 		StandardInput = "socket";
			# 	};
			# };
      #
			# sockets.xflux = sessionTask {
			# 	listenStreams = [ "%t/xflux.sock" ];
			# };

			# services.crashplan = sessionTask {
			# 	path = systemPath;
			# 	serviceConfig = {
			# 		Type="forking";
			# 		PIDFile =    "${home}/crashplan/CrashPlanEngine.pid";
			# 		ExecStart =  "${home}/crashplan/bin/CrashPlanEngine start";
			# 		ExecStop =   "${home}/crashplan/bin/CrashPlanEngine stop";
			# 		ExecReload = "${home}/crashplan/bin/CrashPlanEngine restart";
			# 	};
			# };

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
						"XDG_DATA_DIRS=/usr/local/share/:/usr/share/:${pkgs.shellshape}/share/gnome-shell/extensions/shellshape@gfxmonk.net/data"
						"GIO_EXTRA_MODULES=${pkgs.gnome3.dconf.lib}/lib/gio/modules"
					];
				};
			};
		} [

			(let remocaml = "${home}/dev/web/remocaml"; in optional (builtins.pathExists remocaml) {
				services.web-remote = {
					# needed for `session-vars`
					path = userPath;
					serviceConfig = {
						KillMode = "process";
						Restart = "always";
						ExecStart = "${remocaml}/_build/install/default/bin/remocaml";
						Environment = [
							"REMOCAML_EPHEMERAL=60"
						];
					};
				};
				sockets.web-remote = {
					listenStreams = [ "8076" ];
					wantedBy = [ "default.target" "sockets.target"];
				};
			})

			# (optional (pkgs.gsel or null) {
			# 	# gsel server (if gsel exists)
			# 	services.gsel-server = {
			# 		# wantedBy = [ "default.target" ];
			# 		serviceConfig = {
			# 			ExecStart = "${pkgs.gsel}/bin/gsel --server";
			# 			Environment = "OCAMLRUNPARAM=b";
			# 			Restart = "on-failure";
			# 		};
			# 	};
			# 	sockets.gsel-server = {
			# 		wantedBy = [ "default.target" "sockets.target"];
			# 		listenStreams = [ "@%t/gsel.sock" ];
			# 	};
			# })

		];
		system.build.standalone-user-units = sd.generateUnits
			"user" # type
			(config.systemd.user.units // {
				# Hack; systemd.user.targets should be supported...
				"desktop-session.target" = rec {
					wantedBy = [];
					requiredBy = [];
					aliases = [];
					unit = sd.makeUnit "desktop-session.target" {
						inherit wantedBy requiredBy;
						enable = true;
						text = ''
							[Unit]
						'';
					};
				};
			})

			[ "default.target" "sockets.target" "timers.target"] # upstreamUnits
			[] # upstreamWants
		;
	};
}
