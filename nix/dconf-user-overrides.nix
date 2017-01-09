{ pythonPackages, gnome3 }:
pythonPackages.buildPythonPackage {
	src = /home/tim/dev/python/dconf-user-overrides/nix/local.tgz;
	name = "dconf-user-overrides";
	propagatedBuildInputs = with pythonPackages; [ pygobject3 ];
	postInstall = ''
		wrapProgram $out/bin/dconf-user-overrides \
			--suffix GIO_EXTRA_MODULES : ${gnome3.dconf}/lib/gio/modules \
			;
	'';
}
