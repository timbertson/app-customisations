self: super:
with super.lib;
let
	# TODO: figure out a way to safely use super instead of this
	safeNixpkgs = import <nixpkgs> {};
	home = (import ./session-vars.nix).home;
	wrangleSrc =
		let local = "${home}/dev/nix/nix-wrangle"; in
		if builtins.pathExists local
			then local
			else safeNixpkgs.fetchFromGitHub (importJSON ./nix/wrangle.json).sources.nix-wrangle.fetch;

	wrangleApi = safeNixpkgs.callPackage "${wrangleSrc}/nix/api.nix" {};
	localWrangleSource = ./nix + "/wrangle-${super.hostname}.json";
	wrangleSources = filter builtins.pathExists [ ./nix/wrangle.json localWrangleSource ];

	args = {
		path = ./.;
		sources = wrangleSources;
		extend = sources: let
			overrideCall = name: call:
			if hasAttr name sources
				then listToAttrs [
					{ inherit name; value = (getAttr name sources) // { inherit call; }; }
				] else {}
			; in

			(overrideCall "gup-ocaml" ({pkgs, path}: pkgs.callPackage path { inherit (self) opam2nix nix-wrangle;})) //
			(overrideCall "snip" ({pkgs, path}: self.haskell.packages.ghc865.callPackage path {})) //
			(overrideCall "vim-watch" ({pkgs, path}: pkgs.callPackage path { enableNeovim = true; })) //
			(overrideCall "pyperclip" ({pkgs, path}:
				pkgs.callPackage ({ lib, fetchgit, python3Packages, which, xsel }:
					python3Packages.buildPythonPackage rec {
						name = "pyperclip-${version}";
						version = "dev";
						src = path;
						doCheck = false;
						# nativeBuildInputs = [ which xsel ];
						postInstall = ''
							mkdir -p $out/bin
							cat > $out/bin/pyperclip << EOF
#!/usr/bin/env bash
export PATH="${lib.concatMapStringsSep ":" (p: "${p}/bin") [python3Packages.python which xsel]}"
export PYTHONPATH="$out/${python3Packages.python.sitePackages}"
exec python3 -m pyperclip "\$@"
EOF
							chmod +x $out/bin/pyperclip
						'';
					}
				) {}
			)) //
			{};
	};

	derivations = wrangleApi.derivations args;
	injectOnlyNames = [ "opam2nix" "opam2nixBin"];
	installNames = sort (a: b: a < b) (filter (x: !(elem x injectOnlyNames)) (attrNames derivations));
in
derivations // {
	installedPackages = (super.installedPackages or []) ++ (
		map (name: builtins.getAttr name self) installNames
	);
}
