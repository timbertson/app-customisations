self: super:

let
	# TODO this is a bit hacky... put our called pkgs back
	# into the `pkgs` argument of each module,
	# to reverse the default nixgpks module which reimports with
	# configured overlays, etc.
	overridePkgs = { config, lib, pkgs, ... }@args: with lib; warn "moverride!" {
		config = {
			_module.args = {
				pkgs = mkOverride (modules.defaultPriority - 1) self;
			};
		};
	};

	configuration = { pkgs, ... }@args:
		let fromFile = import ./home.nix args;
		in fromFile // {
			imports = (fromFile.imports or []) ++ [ overridePkgs ];
		};

in {
	installedPackages = super.installedPackages ++ [self.home-manager-activation];
	home-manager-activation = super.lib.warn (builtins.toJSON (super.lib.attrNames self.siteLib)) (self.callPackage "${self.home-manager}/modules" {
		configuration = configuration;
		check = true;
	}).activationPackage;
}
