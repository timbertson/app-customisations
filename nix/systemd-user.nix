{ config, lib, pkgs, utils, ... }:
let
	sd = import <nixpkgs/nixos/modules/system/boot/systemd-lib.nix> { inherit config lib pkgs; };
	optional = x: attrs: if (x == null || x == false) then {} else attrs;
	home = builtins.getEnv "HOME";
	displayEnv = ["DISPLAY=:0"]; # ugh...
	sessionTask = x: {wantedBy = ["desktop-session.target"]; } // x;
	systemPath = [ "/usr/local" "/usr" "/" ];
	loadSessionVars = "eval \"$(session-vars --all --process gnome-shell --export)\"";
	userPath = systemPath ++ [ "${home}" "${home}/dev/app-customisations" "${home}/dev/app-customisations/nix/local" "${home}/.bin/zi"];
in
{
	config = {
		systemd.user = lib.fold lib.recursiveUpdate {
			# album releases cron job
			services.album-releases = {
				serviceConfig = {
					ExecStart = "${pkgs.gup}/bin/gup ${home}/Sites/couch/album-releases/all";
					Restart="no";
					Environment = [
						"PYTHONUNBUFFERED=1"
						"PATH=/usr/bin/:${home}/.bin/zi:${home}/.bin:${home}/bin"
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

			# XXX I wouldn't need to manually invoke xkb if this shift key weren't so broken :(
			timers.xkb = {
				wantedBy = [ "default.target" "timers.target" ];
				timerConfig = {
					OnBootSec = "5s";
					OnUnitActiveSec = "30m";
				};
			};

			services.xkb = sessionTask {
				path = userPath;
				serviceConfig = {
					ExecStart = "${home}/dev/app-customisations/bin/reset-xkb";
					Environment = displayEnv;
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
					ExecStart = "/usr/bin/env 0install run -c ${home}/dev/oni/dns/server.xml --port 5053";
					Environment = "PYTHONUNBUFFERED=1";
					EnvironmentFile = "-%h/.config/dns-alias/env";
				};
			};

			services.xbindkeys = sessionTask {
				path = systemPath;
				serviceConfig = {
					ExecStart = "${pkgs.xbindkeys}/bin/xbindkeys --nodaemon";
					Environment = displayEnv;
					Restart = "always";
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
			# 	#XXX nix-compiled tilda kills all X11 input devices on `sudo`.
			# 	# So use distro-provided tilda because that seems to work
			# 	script = "${loadSessionVars}; /usr/bin/tilda";
			# 	serviceConfig = {
			# 		Environment = displayEnv ++ [
			# 			"TERM_SOLARIZED=1"
			# 			# "XDG_DATA_DIRS=${home}/.local/nix/share:/usr/local/share/:/usr/share/"
			# 			# "SSH_AUTH_SOCK=%t/keyring/ssh"
			# 		];
			# 	};
			# };

			services.rygel = sessionTask {
				path = systemPath;
				serviceConfig = {
					ExecStart = "${pkgs.rygel or "/usr"}/bin/rygel";
				};
			};

			services.xflux = sessionTask {
				serviceConfig = {
					ExecStart = "${pkgs.xflux}/bin/xflux -l 37.7833 -g 144.9667 -k 4600 -nofork";
					Environment = displayEnv;
					# xflux goes nuts when input is /dev/null, probably a read loop somewhere.
					# Just make it a socket which nobody talks to
					StandardInput = "socket";
				};
			};

			sockets.xflux = sessionTask {
				listenStreams = [ "%t/xflux.sock" ];
			};

			services.crashplan = sessionTask {
				path = systemPath;
				serviceConfig = {
					Type="forking";
					PIDFile =    "${home}/crashplan/CrashPlanEngine.pid";
					ExecStart =  "${home}/crashplan/bin/CrashPlanEngine start";
					ExecStop =   "${home}/crashplan/bin/CrashPlanEngine stop";
					ExecReload = "${home}/crashplan/bin/CrashPlanEngine restart";
				};
			};

			timers.daglink = {
				wantedBy = [ "default.target" "timers.target" ];
				timerConfig = {
					OnStartupSec = "10s";
				};
			};
			services.daglink = {
				serviceConfig = {
					ExecStart = "${home}/.bin/daglink -f";
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
					ExecStart = "/usr/bin/env dconf-user-overrides";
				};
			};
		} [

			(optional (builtins.pathExists "${home}/dev/web/remote") {
				services.web-remote = let base = "${home}/dev/web/remote"; in {
					# needed for `session-vars`
					path = userPath;
					serviceConfig = {
						KillMode = "process";
						Restart = "always";
						ExecStart = "${pkgs.nodejs}/bin/node ${base}/node_modules/conductance/conductance serve ${base}/config.mho";
						Environment = [
							# "NODE_PATH=${home}/dev/oni"
							"NODE_ENV=production"
						];
					};
				};
				sockets.web-remote = {
					listenStreams = [ "8076" ];
					wantedBy = [ "default.target" "sockets.target"];
				};
			})

			({
				services.edit-server = {
					path = [ "${home}/.bin" ];
					serviceConfig = {
						ExecStart = "/usr/bin/env 0install run -c http://gfxmonk.net/dist/0install/edit-server.xml";
					};
				};
				sockets.edit-server = {
					listenStreams = [ "9292" ];
					wantedBy = [ "default.target" "sockets.target"];
				};
			})

			(optional (pkgs.gsel or null) {
				# gsel server (if gsel exists)
				services.gsel-server = {
					# wantedBy = [ "default.target" ];
					serviceConfig = {
						ExecStart = "${pkgs.gsel}/bin/gsel --server";
						Environment = "OCAMLRUNPARAM=b";
						Restart = "on-failure";
					};
				};
				sockets.gsel-server = {
					wantedBy = [ "default.target" "sockets.target"];
					listenStreams = [ "@%t/gsel.sock" ];
				};
			})

		];
		system.build.standalone-user-units = sd.generateUnits
			"user" # type
			(config.systemd.user.units // {
				# Hack; systemd.user.targetss should be supported...
				"desktop-session.target" = rec {
					wantedBy = [];
					requiredBy = [];
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
