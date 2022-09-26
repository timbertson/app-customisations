{ pkgs, config, lib, ... }:
with lib;
with pkgs;
with pkgs.siteLib;
let
	maximal = ifEnabled "maximal";
	darwin = pkg: orNull stdenv.isDarwin pkg;
	linux = pkg: orNull stdenv.isLinux pkg;
	warnNull = desc: opt: if opt == null then warn "${desc} is null" null else warn "${desc} is DEFINED!" opt;
in {
	# Don't try to install with `nix-env` during activation, I'll
	# setup $PATH and friends myself
	# TODO: spit out bashrc / fishrc for this?
	submoduleSupport.externalPackageInstall = true;

	home.packages = builtins.trace "Features: ${builtins.toJSON pkgs.features}" (
		with pkgs; lib.remove null (pkgs.installedPackages ++ [
			home-manager
			(darwin coreutils)
			(darwin cacert)
			(darwin fswatch)
			direnv
			dtach
			(pkgs.gup-ocaml or gup)
			fish
			fzf
			(linux gnomeExtensions.quake-mode)
			(darwin git)
			(pkgs.irank or null)
			irank-releases
			(ifEnabled "jdk" my-jdks)
			(anyEnabled [ "node" "maximal"] nodejs)
			nix
			niv
			my-caenv
			my-neovim
			pyperclip-bin
			python3Packages.python
			ripgrep
		]
		++ map maximal (
			[
				glibcLocales
				python3Packages.ipython
				python3Packages.youtube-dl
			] ++ map linux [
				# linux + maximal
				jsonnet
				nixGL.nixGLIntel
				ocaml
				parcellite
				my-qt5
				xbindkeys
			]) # /maximal
		)
	);
}
