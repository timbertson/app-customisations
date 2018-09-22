{
	# glibc = { locales = true; };
	allowUnfree = true;
	allowBroken = true; # e.g. pathpy
	allowUnsupportedSystem = true;
	packageOverrides = pkgs: with pkgs;
		let
			HOME = builtins.getEnv "HOME";
		in
	{
		nix-pin = (pkgs.nix-pin.api {}).pins.nix-pin or pkgs.nix-pin;
		sitePackages = if builtins.pathExists "${HOME}/dev/app-customisations/nix"
			then
				(import (/. + HOME + "/dev/app-customisations/nix/packages.nix") { inherit pkgs; })
				// {recurseForDerivations = false; }
			else null;
		jre = jre8;
	};
}

