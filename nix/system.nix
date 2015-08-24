{
	pkgs ? import <nixpkgs> {},
}:
with pkgs;
lib.evalModules {
	modules = [
		({lib, ...}:
		{
			config = {
				# _module.check = false;  # we're building a partial nixos here; just ignore unknown config options
				_module.args = { inherit pkgs; };
				nixpkgs.system = builtins.currentSystem;
			};
			# so that we can include _module check; we define & ignore
			# whatever options nix complains about here:
			options = with lib; let ignore = mkOption { type = types.unspecified; }; in {
				users = ignore;
				security = ignore;
				system.requiredKernelConfig = ignore;
			};
		})
		./modules/user-session.nix
		
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
}

