{ pkgs, nix-wrangle }:
self: super:
with super.lib;
let
	wrangleApi = nix-wrangle.api { pkgs = self; };
	localWrangleSource = ./. + "/wrangle-${super.hostname}.json";
	wrangleSources = filter builtins.pathExists [ ./wrangle.json localWrangleSource ];

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
			(overrideCall "remocaml" ({pkgs, path}: (pkgs.callPackage path {}).remocaml)) //
			(overrideCall "snip" ({pkgs, path}: self.haskell.packages.ghc865.callPackage path {})) //
			(overrideCall "vim-watch" ({pkgs, path}: pkgs.callPackage path { enableNeovim = true; })) //
			(overrideCall "nix-wrangle" ({pkgs, path}: pkgs.callPackage path { enableSplice = false; })) //
			{};
	};

	derivations = filterAttrs (name: value: name != "pkgs") (wrangleApi.derivations args);
	injectOnlyNames = [ "opam2nix" "opam2nixBin" "home-manager-src" "gup-ocaml" "gnome-shell-rearrange-system-menu" "nixGL" "ocaml-lsp-src"];
	installNames = sort (a: b: a < b) (filter (x: !(elem x injectOnlyNames)) (attrNames derivations));
in
derivations // {
	installedPackages = (super.installedPackages or []) ++ (
		map (name: builtins.getAttr name self) installNames
	);
}
