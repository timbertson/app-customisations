self: super:
# let appCustomisations = import ./overlay.nix super self; in
{

	# disable fancy language server rubbish
	python3Packages = super.python3Packages // {
		python-language-server = super.python3Packages.python-language-server.override { providers = []; };
	};

	jre = self.jre8;
	# docker-credential-gcr = let o = pkgs.docker-credential-gcr; in lib.extendDerivation true {
	# 	meta = (o.meta // { platforms = go.meta.platforms; });
	# } o;
}

