{ stdenv, fetchurl }:
let
  version = "0.8.5";
in
stdenv.mkDerivation {
	name = "jsonnet-${version}";
	src = fetchurl {
		url = "https://github.com/google/jsonnet/archive/v${version}.tar.gz";
		sha256 = "1b6whj7ad0zlq3smrnf6c6friipkgny6kqdcbjnbll21jmpzhkai";
	};
	makeFlags = "libjsonnet.so jsonnet";
	installPhase = ''
		mkdir $out
		mkdir $out/bin
		mkdir $out/lib
		cp jsonnet $out/bin/
		cp libjsonnet.so $out/lib/
	'';
}

