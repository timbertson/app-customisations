{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation {
	name = "vim-watch";
	src = fetchgit {
		url = "https://github.com/gfxmonk/vim-watch";
		rev = "983cbd95797251097fe0a00eedcac75aa6bbff8c";
		sha256 = "6c55742c10ba62d8021808efad211410cd087f0254ee23911755934eef0df088";
	};
	buildInputs = [ python ];
	installPhase = ''
		mkdir -p $out/share/vim;
		cp -a ./* $out/share/vim
		mv $out/share/vim/bin $out/bin
	'';
}
