{ pythonPackages, gnome3 }:
pythonPackages.buildPythonPackage {
	src = /home/tim/dev/python/irank/nix/local.tgz;
	name = "irank";
	propagatedBuildInputs = with pythonPackages; [ mutagen pyyaml dbus-python pygobject2 ];
}
