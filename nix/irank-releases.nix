{ lib, stdenv, makeWrapper, pythonPackages }:
let
	pythonDeps = with pythonPackages; [ musicbrainzngs pyyaml ];
in
stdenv.mkDerivation {
	name = "irank-releases";
	buildInputs = [ makeWrapper ];
	propagatedBuildInputs = pythonDeps;
	buildCommand =
		let pythonpath =
			lib.concatStringsSep ":" (map (dep: "${dep}/lib/${pythonPackages.python.libPrefix}/site-packages") pythonDeps);
		in
		''
			mkdir -p "$out/bin"
			makeWrapper ${../bin/irank-releases.py} "$out/bin/irank-releases" \
				--prefix PYTHONPATH : ${pythonpath} \
				;
		'';
}


