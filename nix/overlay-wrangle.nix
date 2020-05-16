self: super:
with super.lib;
let
	# TODO: figure out a way to safely use super instead of this
	safeNixpkgs = (import ./nixpkgs.nix).system {};
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

			(overrideCall "opam2nix" ({pkgs, path}: pkgs.callPackage path { inherit (self); ocamlPackages = super.ocaml-ng.ocamlPackages_4_08; })) //
			(overrideCall "gup-ocaml" ({pkgs, path}: pkgs.callPackage path { inherit (self) opam2nix nix-wrangle;})) //
			(overrideCall "snip" ({pkgs, path}: self.haskell.packages.ghc865.callPackage path {})) //
			(overrideCall "vim-watch" ({pkgs, path}: pkgs.callPackage path { enableNeovim = true; })) //
			(overrideCall "nix-wrangle" ({pkgs, path}: pkgs.callPackage path { enableSplice = false; })) //
			{};
	};

	derivations = filterAttrs (name: value: name != "pkgs") (wrangleApi.derivations args);
	injectOnlyNames = [ "opam2nix" "opam2nixBin" "home-manager-src" "gup-ocaml" "gnome-shell-rearrange-system-menu"];
	installNames = sort (a: b: a < b) (filter (x: !(elem x injectOnlyNames)) (attrNames derivations));
in
derivations // {
	installedPackages = (super.installedPackages or []) ++ (
		map (name: builtins.getAttr name self) installNames
	);
}
