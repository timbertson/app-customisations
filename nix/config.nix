{
	allowUnfree = true;
	allowBroken = true; # e.g. pathpy
	packageOverrides = pkgs: with pkgs;
		let
			HOME = builtins.getEnv "HOME";
		in
	{
		sitePackages = if builtins.pathExists "${HOME}/dev/app-customisations/nix"
			then
				(import (/. + HOME + "/dev/app-customisations/nix/packages.nix") { inherit pkgs; })
				// {recurseForDerivations = false; }
			else null;
		jre = jre8;
	};
}

