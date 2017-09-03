{ lib, stdenv, makeWrapper, pythonPackages, irank }:
let
	pythonDeps = [ irank ] ++ (with pythonPackages; [ musicbrainzngs pyyaml ]);
	pythonpath = lib.concatStringsSep ":" (map (dep: "${dep}/lib/${pythonPackages.python.libPrefix}/site-packages") pythonDeps);
in
stdenv.mkDerivation {
	name = "irank-releases";
	buildInputs = [ makeWrapper ];
	shellHook = ''
		export PYTHONPATH="${pythonpath}"
	'';
	buildCommand =
		''
			mkdir -p "$out/bin"
			makeWrapper ${../bin/irank-releases.py} "$out/bin/irank-releases" \
				--prefix PYTHONPATH : ${pythonpath} \
				;
		'';
}


