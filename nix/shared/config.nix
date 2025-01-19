{
	allowUnfree = true;
	allowBroken = true; # e.g. pathpy
	allowUnsupportedSystem = true;
	# glibc = { locales = true; };
	permittedInsecurePackages = [
		"python-2.7.18.6"
		"python-2.7.18.7"
		"python-2.7.18.8"
		"python2.7-Pillow-6.2.2"
		"nix-2.15.3"
	];
}
