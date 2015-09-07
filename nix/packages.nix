{pkgs ? import <nixpkgs> {}}:
with pkgs;
let
	home = builtins.getEnv "HOME";
	tryImport = path: if builtins.pathExists path then (import (builtins.toPath path) {inherit pkgs;}) else null;
	opam2nix-packages = callPackage ./opam2nix-packages.nix {};
in
pkgs // rec {
	daglink = callPackage ./daglink.nix {};
	gup = let
		local = tryImport "${home}/dev/ocaml/gup/local.nix";
		fallback = callPackage ./gup-python.nix {};
	in if local != null then local else fallback;
	gsel = tryImport "${home}/dev/ocaml/gsel/default.nix";
	vim-watch = callPackage ./vim-watch.nix {};
	vim = (callPackage ./vim.nix { pluginArgs = { inherit gsel vim-watch; }; });
	shellshape = tryImport "${home}/dev/gnome-shell/shellshape@gfxmonk.net/local.nix";
	zeroinstall = opam2nix-packages.buildPackage "0install" {};
	passe-client = let builder = tryImport "${home}/dev/ocaml/passe/nix/local.nix"; in
		if builder == null then null else builder { target="client"; };
}
