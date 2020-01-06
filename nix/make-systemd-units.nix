{ lib, runCommand, callPackage, units }:
let system = lib.evalModules {
		modules = [
			({config, lib, pkgs, ...}:
			let sd = import <nixpkgs/nixos/modules/system/boot/systemd-lib.nix> { inherit config lib pkgs; }; in
			{
				config = {
					# _module.check = false;  # we're building a partial nixos here; just ignore unknown config options
					# _module.args = { pkgs = self; };
					nixpkgs.system = builtins.currentSystem;
					systemd.user = units;
					system.build.standalone-user-units = (sd.generateUnits
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
					);
				};
				# so that we can include _module check; we define & ignore
				# whatever options nix complains about here:
				options = with lib; let ignore = mkOption { type = types.unspecified; }; in {
					users = ignore;
					security = ignore;
					system.requiredKernelConfig = ignore;
					services.dbus = ignore;
					environment.systemPackages = ignore;
				};
			})
			
			<nixpkgs/nixos/modules/system/boot/systemd.nix>
			<nixpkgs/nixos/modules/system/etc/etc.nix>

			<nixpkgs/nixos/modules/system/activation/activation-script.nix>
			<nixpkgs/nixos/modules/system/activation/top-level.nix>

			# include all misc/* helpers
			<nixpkgs/nixos/modules/misc/assertions.nix>
			<nixpkgs/nixos/modules/misc/crashdump.nix>
			<nixpkgs/nixos/modules/misc/extra-arguments.nix>
			<nixpkgs/nixos/modules/misc/ids.nix>
			<nixpkgs/nixos/modules/misc/lib.nix>
			<nixpkgs/nixos/modules/misc/locate.nix>
			<nixpkgs/nixos/modules/misc/meta.nix>
			<nixpkgs/nixos/modules/misc/nixpkgs.nix>
			<nixpkgs/nixos/modules/misc/passthru.nix>
			<nixpkgs/nixos/modules/misc/version.nix>
		];
}; in
runCommand "systemd-units" {} ''
	mkdir -p $out/share/systemd
	cp -a "${system.config.system.build.standalone-user-units}" $out/share/systemd/user
''
