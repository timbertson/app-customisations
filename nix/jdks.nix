{ pkgs }:
with pkgs;
stdenv.mkDerivation {
	name = "jdks";
	buildCommand = ''
		dest="$out/jdk"
		mkdir -p "$dest"
		ln -s "${openjdk}" "$dest/8"
		ln -s "${openjdk11}" "$dest/11"
	'';
}

