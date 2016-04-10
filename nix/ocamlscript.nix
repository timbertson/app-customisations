{ pkgs ? import <nixpkgs> {}}:
with pkgs;
let src = fetchgit {
  fetchSubmodules = true;
  url = "https://github.com/bloomberg/ocamlscript.git";
  rev = "659250a9b76f02643648f64c51ba577cf2c68564";
  sha256 = "8b6cd4b05434d6c1afa686260eebfd72779b3b958c9d003c709c7eb3069584fd";
};

ocaml = 
  lib.overrideDerivation pkgs.ocaml_4_02 (o: {
    buildInputs = o.buildInputs ++ [ git ];
    src = "${src}/ocaml";
    patches = []; # sure hope they didn't matter :/
    buildFlags = "world.opt";
    preConfigure = ''git apply ${src}/js.diff'';
  });
in
stdenv.mkDerivation {
  name = "ocamlscript";
  inherit src;
  buildInputs = [ ocaml makeWrapper ];
  buildPhase = ''
    cd jscomp
    ocamlopt.opt -I +compiler-libs -I bin -c bin/compiler.mli bin/compiler.ml
    ocamlopt.opt -g -linkall -o bin/ocamlscript -I +compiler-libs ocamlcommon.cmxa ocamlbytecomp.cmxa  bin/compiler.cmx main.cmx
    export PATH=$PWD/bin:$PATH
    make -C runtime all
    make -C stdlib all
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp -r runtime stdlib $out/
    cp bin/ocamlscript $out/bin/
    wrapProgram $out/bin/ocamlscript \
      --add-flags -I \
      --add-flags $out \
      ;
  '';
}
