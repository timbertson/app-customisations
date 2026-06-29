{
	allowUnfree = true;
	allowBroken = true; # e.g. pathpy
	allowUnsupportedSystem = true;
	# glibc = { locales = true; };
	permittedInsecurePackages = [
		"python-2.7.18.6"
		"python-2.7.18.7"
		"python-2.7.18.8"
		"pypy2.7-setuptools-44.0.0"
		"python2.7-Pillow-6.2.2"
		"pypy2.7-pip-20.3.4"
		"nix-2.15.3"
	];
}
