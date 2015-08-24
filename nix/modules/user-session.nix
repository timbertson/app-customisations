{ config, lib, pkgs, utils, ... }:
let
	sd = import <nixpkgs/nixos/modules/system/boot/systemd-lib.nix> { inherit config lib pkgs; };
	optional = x: attrs: if x == null then {} else attrs;
	enabled = attrs: attrs // { enable = true; };
	home = builtins.getEnv "HOME";
in
{
	config = {
		systemd.user = lib.fold lib.recursiveUpdate {
			# album releases cron job
			services.album-releases = enabled {
				serviceConfig = {
					ExecStart = "${pkgs.gup}/bin/gup ${home}/Sites/couch/album-releases/all";
					Restart="no";
					Environment = [
						"PYTHONUNBUFFERED=1"
						"PATH=/usr/bin/:${home}/.bin/zi:${home}/.bin:${home}/bin"
					];
				};
			};
			timers.album-releases = enabled {
				wantedBy = [ "default.target" "timers.target" ];
				timerConfig = {
					OnCalendar = "21:00:00";
					Persistent = true;
				};
			};

			# usermode DNS alias
			sockets.dns-alias = enabled {
				wantedBy = [ "default.target" "sockets.target"];
				socketConfig = {
					ListenDatagram = "127.0.0.1:5053";
				};
			};
			services.dns-alias = enabled {
				serviceConfig = {
					ExecStart = "/usr/bin/env 0install run -c ${home}/dev/oni/dns/server.xml --port 5053";
					Restart = "always";
					Environment = "PYTHONUNBUFFERED=1";
					EnvironmentFile = "-%h/.config/dns-alias/env";
				};
			};
		} [

			(optional (pkgs.gsel or null) {
				# gsel server (if gsel exists)
				services.gsel-server = enabled {
					# wantedBy = [ "default.target" ];
					serviceConfig = {
						ExecStart = "${pkgs.gsel}/bin/gsel --server";
						Environment = "OCAMLRUNPARAM=b";
						Restart = "on-failure";
					};
				};
				sockets.gsel-server = enabled {
					wantedBy = [ "default.target" "sockets.target"];
					listenStreams = [ "@%t/gsel.sock" ];
				};
			})

		];
		system.build.standalone-user-units = sd.generateUnits
			"user" # type
			config.systemd.user.units
			[ "default.target" "sockets.target" "timers.target"] # upstreamUnits
			[] # upstreamWants
		;
	};
}
