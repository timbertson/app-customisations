{
	allowUnfree = true;
	allowBroken = true; # e.g. pathpy
	packageOverrides = pkgs: with pkgs;
		let
			HOME = builtins.getEnv "HOME";
		in
	{
		libffi = lib.overrideDerivation pkgs.libffi (o: {
			# hacky workaround for https://github.com/libffi/libffi/issues/293
			configureFlags = (o.configureFlags or []) ++ ["CFLAGS=-DFFI_MMAP_EXEC_SELINUX=0"];
		});

		sitePackages = if builtins.pathExists "${HOME}/dev/app-customisations/nix"
			then
				(import (/. + HOME + "/dev/app-customisations/nix/packages.nix") { inherit pkgs; })
				// {recurseForDerivations = false; }
			else null;
	};
}

