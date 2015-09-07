{pkgs ? import <nixpkgs> {}}:
with pkgs;
with pythonPackages;
let
  version = "0.5";
in
stdenv.mkDerivation {
  name = "daglink-${version}";
  src = fetchgit {
    url = "https://github.com/gfxmonk/daglink.git";
    rev = "66856cd94061742ecd51b4f46ce7ceae69fccbec";
    sha256 = "fea9a0cb17d8dbca78297056d3baf7bd69c4143ffdc2beaf8d69cce1bb893692";
  };
  buildInputs = [ python makeWrapper pyyaml ];
  buildPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    cp daglink.py $out/bin/daglink
    wrapProgram $out/bin/daglink \
      --set PYTHONPATH "$PYTHONPATH" \
      ;
   '';
}
