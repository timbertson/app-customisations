{pkgs ? import <nixpkgs> {}}:
with pkgs;
let
	home = builtins.getEnv "HOME";
	tryImport = path: args: if builtins.pathExists path
		then (import (builtins.toPath path) ({ inherit pkgs; } // args))
		else null;
	default = dfl: obj: if obj == null then dfl else obj;
	opam2nix-packages = callPackage ./opam2nix-packages.nix {};
	buildFromGitHub = jsonFile:
		let
			json = lib.importJSON jsonFile;
			repoContents = fetchFromGitHub (json.params);
			pkg = (callPackage "${repoContents}/nix/default.nix" {
				fetchFromGitHub = params:
					if params.repo == json.inputs.repo
						then repoContents # always return the version we imported. Otherwise we'll get the version _just before_ the one we imported (at time of tagging, the new release didn't exist)
						else fetchFromGitHub params;
			});
		in
		lib.overrideDerivation pkg (base: {
			name = "${json.inputs.repo}-${json.inputs.version}";
		});
in
pkgs // rec {
	inherit tryImport default buildFromGitHub;
	daglink = (buildFromGitHub ./sources/daglink.json);
	opam2nix = opam2nix-packages.opam2nix;
	gup = default pkgs.gup (tryImport "${home}/dev/ocaml/gup/local.nix" {});
	gsel = tryImport "${home}/dev/ocaml/gsel/default.nix" {};
	vim-watch = callPackage ./vim-watch.nix {};
	vim = (callPackage ./vim.nix { pluginArgs = { inherit gsel vim-watch; }; });
	shellshape = tryImport "${home}/dev/gnome-shell/shellshape@gfxmonk.net/local.nix" {};
	# zeroinstall = builtins.getAttr "0install" (opam2nix-packages.buildPackageSet { packages=["0install" "obus"]; });
	# obus = (opam2nix-packages.buildPackageSet { packages=["obus"]; }).obus;
	jsonnet = callPackage ./jsonnet.nix {};
	eog-rate = tryImport "${home}/dev/python/eog-rate/nix/local.nix" {};
	dumbattr = tryImport "${home}/dev/python/dumbattr/nix/local.nix" {};
	trash = tryImport "${home}/dev/python/trash/default.nix" {};
	music-import = tryImport "${home}/dev/python/music-import/nix/local.nix" {};
	my-nix-prefetch-scripts = callPackage ./nix-prefetch-scripts.nix {};
	passe-client = let builder = tryImport "${home}/dev/ocaml/passe-stable/nix/local.nix" {}; in
		if builder == null then null else builder { target="client"; };
}
