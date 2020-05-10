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
			git-wip
			(darwin git)
			(pkgs.irank or null)
			irank-releases
			(ifEnabled "jdk" my-jdks)
			(ifEnabled "gnome-shell" my-gnome-shell-extensions)
			(anyEnabled [ "node" "maximal"] nodejs)
			nix
			my-caenv
			neovim
			neovim-remote
			# (ifEnabled "vim-ide" ocaml-language-server)
			# (ifEnabled "vim-ide" python3Packages.python-language-server)
			pyperclip-bin
			python3Packages.python
			ripgrep
			vim-watch
		]
		++ map maximal (
			[
				glibcLocales
				python3Packages.ipython
				python3Packages.youtube-dl
			] ++ map linux [
				# linux + maximal
				jsonnet
				ocaml
				parcellite
				my-qt5
				xbindkeys
			]) # /maximal
		)
	);
}
