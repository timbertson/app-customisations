{ config, lib, pkgs, utils, ... }:
let
	sd = import <nixpkgs/nixos/modules/system/boot/systemd-lib.nix> { inherit config lib pkgs; };
	optional = x: attrs: if (x == null || x == false) then {} else attrs;
	home = builtins.getEnv "HOME";
	displayEnv = ["DISPLAY=:0"]; # ugh...
	sessionTask = x: {wantedBy = ["desktop-session.target"]; } // x;
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
				serviceConfig = {
					ExecStart = "${pkgs.xbindkeys}/bin/xbindkeys";
					Environment = displayEnv;
				};
			};
			services.guake = sessionTask {
				path = [ "/usr" ];
				serviceConfig = {
					ExecStart = "${pkgs.guake or "/usr"}/bin/guake";
					Environment = displayEnv;
				};
			};

			services.rygel = sessionTask {
				path = [ "/usr" ];
				serviceConfig = {
					ExecStart = "${pkgs.rygel or "/usr"}/bin/rygel";
				};
			};

			services.xflux = sessionTask {
				serviceConfig = {
					ExecStart = "${pkgs.xflux}/bin/xflux -l 37.7833 -g 144.9667 -k 4600 -nofork";
					Environment = displayEnv;
				};
			};

			services.crashplan = sessionTask {
				path = [ "/usr" ];
				serviceConfig = {
					Type="forking";
					PIDFile =    "${home}/crashplan/CrashPlanEngine.pid";
					ExecStart =  "${home}/crashplan/bin/CrashPlanEngine start";
					ExecStop =   "${home}/crashplan/bin/CrashPlanEngine stop";
					ExecReload = "${home}/crashplan/bin/CrashPlanEngine restart";
				};
			};

			# timers.daglink = {
			# 	wantedBy = [ "default.target" "timers.target" ];
			# 	timerConfig = {
			# 		OnStartupSec = "10s";
			# 	};
			# };
			# services.daglink = {
			# 	serviceConfig = {
			# 		ExecStart = "${home}/.bin/daglink -f";
			# 	};
			# };

			timers.dconf-user-overrides = {
				wantedBy = [ "default.target" "timers.target" ];
				timerConfig = {
					OnStartupSec = "0s";
				};
			};
			services.dconf-user-overrides = {
				path = [ home ];
				serviceConfig = {
					ExecStart = "${home}/.bin/daglink -f";
				};
			};
		} [

			(optional (builtins.pathExists "${home}/dev/web/remote") {
				services.web-remote = let base = "${home}/dev/web/remote"; in {
					# needed for `dbus-session-vars`
					path = [ "/bin:/usr/bin:${home}/dev/app-customisations" ];
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
