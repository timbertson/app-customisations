{pkgs ? import <nixpkgs> {}}:
with pkgs;
let
	home = builtins.getEnv "HOME";
	tryImport = path: args: if builtins.pathExists path
		then (import (builtins.toPath path) ({ inherit pkgs; } // args))
		else null;
	tryCallPackage = path: args: if builtins.pathExists path
		then (callPackage (builtins.toPath path) args)
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
	dconf-user-overrides = callPackage ./dconf-user-overrides.nix {};
	dns-alias = tryCallPackage "${home}/dev/python/dns-alias/nix/default.nix" { inherit pythonPackages; };
	dumbattr = tryImport "${home}/dev/python/dumbattr/nix/local.nix" {};
	eog-rate = tryImport "${home}/dev/python/eog-rate/nix/local.nix" {};
	gsel = tryImport "${home}/dev/ocaml/gsel/default.nix" {};
	gup = default pkgs.gup (tryImport "${home}/dev/ocaml/gup/local.nix" {});
	irank = callPackage ./irank.nix {};
	irank-releases = callPackage ./irank-releases.nix {};
	jsonnet = callPackage ./jsonnet.nix {};
	music-import = tryImport "${home}/dev/python/music-import/nix/local.nix" {};
	my-nix-prefetch-scripts = callPackage ./nix-prefetch-scripts.nix {};
	opam2nix = opam2nix-packages.opam2nix;
	passe-client = let builder = tryImport "${home}/dev/ocaml/passe-stable/nix/local.nix" {}; in
		if builder == null then null else builder { target="client"; };
	pyperclip = callPackage ./pyperclip.nix {};
	pythonPackages = pkgs.pythonPackages // {
		dnslib = tryCallPackage "${home}/dev/python/dns-alias/nix/dnslib.nix" { inherit pythonPackages; };
	};
	shellshape = tryImport "${home}/dev/gnome-shell/shellshape@gfxmonk.net/local.nix" {};
	snip = tryImport "${home}/dev/haskell/snip/nix/default.nix" {};
	trash = tryImport "${home}/dev/python/trash/default.nix" {};
	vim = (callPackage ./vim.nix { pluginArgs = { inherit gsel vim-watch; }; });
	vim-watch = callPackage ./vim-watch.nix {};
}
