self: super:

let
	configuration = { pkgs, ... }@args: {
		require = [
			(import ./modules/nixpkgs.nix self)
			./modules/installed-derivations.nix
			./files.nix
			./modules/packages.nix
			./modules/services.nix
			./modules/dconf.nix
		] ++ (if builtins.pathExists ./modules/local.nix then [ ./modules/local.nix ] else []);
	};

	home-manager = (self.callPackage "${self.home-manager}/modules" {
		configuration = configuration;
		check = true;
	});

in {
	home-activation = home-manager.activationPackage;
	home-config = home-manager.config;
}
