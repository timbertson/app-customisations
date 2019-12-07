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
	wrangleSources = filter builtins.pathExists [
		./nix/wrangle.json
		(./nix + "/wrangle-${super.hostname}.json")
	];

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

			(overrideCall "snip" ({pkgs, path}: self.haskell.packages.ghc864.callPackage path {})) //
			(overrideCall "vim-watch" ({pkgs, path}: pkgs.callPackage path { enableNeovim = true; })) //
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
