{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation {
	name = "vim-watch";
	src = fetchgit {
		url = "https://github.com/gfxmonk/vim-watch";
		rev = "382aea1469dc832154e7c1aaf7c43923c1973155";
		sha256 = "5e13dd3034e0a2559e87b9d0efeeebce2edbbefd95ff9b84d452bc097bd3f04d";
	};
	buildInputs = [ python ];
	installPhase = ''
		mkdir -p $out/share/vim;
		cp -a ./* $out/share/vim
		mv $out/share/vim/bin $out/bin
	'';
}
