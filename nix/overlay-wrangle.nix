{ pkgs, nix-wrangle }:
self: super:
with super.lib;
let
	wrangleApi = nix-wrangle.api { pkgs = self; };
	localWrangleSource = ./. + "/wrangle-${super.etc-hostname}.json";
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
			(overrideCall "remocaml" ({pkgs, path}: (pkgs.callPackage path { inherit (self) opam2nix; }).remocaml)) //
			(overrideCall "passe" ({pkgs, path}: (pkgs.callPackage path { inherit (self) opam2nix; }))) //
			(overrideCall "vim-watch" ({pkgs, path}: pkgs.callPackage path { enableNeovim = false; })) //
			(overrideCall "nix-wrangle" ({pkgs, path}: pkgs.callPackage path { enableSplice = false; })) //
			{};
	};

	derivations = filterAttrs (name: value: name != "pkgs") (wrangleApi.derivations args);
	injectOnlyNames = [
		"gnome-shell-rearrange-system-menu"
		"gup-ocaml"
		"nixGL"
		"opam2nix"
		"opam2nixBin"
		"fetlock" # TEMP
		"vim-watch" # temporary, while neovim-remote is failing to build
	];
	installNames = sort (a: b: a < b) (filter (name: !((hasSuffix "-src" name) || (elem name injectOnlyNames))) (attrNames derivations));
in
derivations // {
	installedPackages = (super.installedPackages or []) ++ (
		map (name: builtins.getAttr name self) installNames
	);
}
