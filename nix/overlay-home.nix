self: super:

let
	commonModules = [
		(import ./modules/nixpkgs.nix self)
		./modules/installed-derivations.nix
		./files.nix
		./modules/packages.nix
	];
	platformModules = if super.stdenv.isLinux then [
		./modules/services.nix
		./modules/dconf.nix
	] else [];
	optionalModules = super.lib.filter builtins.pathExists [
		./modules/local.nix
	];

	configuration = { pkgs, ... }@args: {
		require = commonModules ++ optionalModules ++ platformModules;
		home = {
			# I don't think these are used, but need to be defined
			stateVersion = "22.05";
			username = builtins.getEnv "USER";
			homeDirectory = builtins.getEnv "HOME";
		};
	};

	home-manager = (self.callPackage "${super.home-manager-src}/modules" {
		configuration = configuration;
		check = true;
	});

in {
	home-activation = home-manager.activationPackage;
	home-config = home-manager.config;
	home-manager = (self.callPackage "${super.home-manager-src}/default.nix" {}).home-manager;
}
