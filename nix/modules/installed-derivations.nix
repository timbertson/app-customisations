{ lib, config, ... }:
with lib;
{
	options = {
		installedDerivations = mkOption {
			type = types.unspecified;
			default = [];
			description = "Derivations for all installed packages";
		};
	};

	config.installedDerivations = map (o: o.drvPath) config.home.packages;
}
