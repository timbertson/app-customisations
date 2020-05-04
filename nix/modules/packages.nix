{ pkgs, config, lib, ... }:
with lib;
with pkgs;
with pkgs.siteLib;
let
			maximal = ifEnabled "maximal";
			darwin = pkg: orNull stdenv.isDarwin pkg;
			linux = pkg: orNull stdenv.isLinux pkg;
in {
	# Don't try to install with `nix-env` during activation, I'll
	# setup $PATH and friends myself
	# TODO: spit out bashrc / fishrc for this?
	submoduleSupport.externalPackageInstall = true;

	home.packages = builtins.trace "Features: ${builtins.toJSON pkgs.features}" (
		with pkgs; lib.remove null (pkgs.installedPackages ++ [
			home-manager
			daglink
			(darwin coreutils)
			(darwin cacert)
			(darwin fswatch)
			direnv
			dtach
			(self.gup-ocaml or gup)
			fish
			fzf
			git-wip
			(if (stdenv.isDarwin) then null else git)
			(self.irank or null)
			irank-releases
			(ifEnabled "jdk" (callPackage ../jdks.nix {}))
			(ifEnabled "gnome-shell" my-gnome-shell-extensions)
			(anyEnabled [ "node" "maximal"] nodejs)
			nix
			my-caenv
			neovim
			neovim-remote
			pyperclip-bin
			python3Packages.python
			ripgrep
			vim-watch
		]
		++ map (ifEnabled "vim-ide") [
			# ocaml-language-server
			# python3Packages.python-language-server
		] ++ map maximal (
			[
				# maximal:
				ctags
				glibcLocales
				python3Packages.ipython
				python3Packages.youtube-dl
				syncthing
			] ++ map linux [
				# linux + maximal
				# my-desktop-session
				jsonnet
				my-gnome-shell-extensions

				ocaml
				parcellite
				my-qt5
				xbindkeys
			]) # /maximal
		)
	);
}
