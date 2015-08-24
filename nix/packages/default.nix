{pkgs ? import <nixpkgs> {}}:
with pkgs;
let
	home = builtins.getEnv "HOME";
	tryImport = path: if builtins.pathExists path then (import (builtins.toPath path) {inherit pkgs;}) else null;
in
pkgs // (lib.filterAttrs (name: val: val!=null) rec {
	# XXX change this to `default.nix`?
	gup = tryImport "${home}/dev/ocaml/gup/local.nix";
	gsel = tryImport "${home}/dev/ocaml/gsel/default.nix";
	vim_watch = callPackage ./vim-watch.nix {};
	vim = (callPackage ./vim.nix { pluginArgs = { inherit gsel vim_watch; }; });
})
