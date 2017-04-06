{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation {
	name = "vim-watch";
	src = fetchgit {
		url = "https://github.com/gfxmonk/vim-watch";
		rev = "382aea1469dc832154e7c1aaf7c43923c1973155";
		sha256 = "1hxv6a14wsjbn0nncgy3nl7kw428zy3l11j415y8nmvkr73y55jn";
	};
	buildInputs = [ python ];
	installPhase = ''
		mkdir -p $out/share/vim;
		cp -a ./* $out/share/vim
		mv $out/share/vim/bin $out/bin
	'';
}
