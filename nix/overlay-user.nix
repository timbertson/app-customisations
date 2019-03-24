self: super:
let appCustomisations = import ./overlay.nix super self; in
{
	config = super.config // {
		# glibc = { locales = true; };
		allowUnfree = true;
		# allowBroken = true; # e.g. pathpy
		allowUnsupportedSystem = true;
	};

	# disable fancy language server rubbish
	python3Packages = super.python3Packages // { inherit (appCustomisations.python3Packages) python-language-server; };
	jre = self.jre8;
	# docker-credential-gcr = let o = pkgs.docker-credential-gcr; in lib.extendDerivation true {
	# 	meta = (o.meta // { platforms = go.meta.platforms; });
	# } o;
}

