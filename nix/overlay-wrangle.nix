self: super:
with super.lib;
let
	# TODO: figure out a way to safely use super instead of this
	safeNixpkgs = import <nixpkgs> {};
	home = builtins.getEnv "HOME";
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
		extend = (sources: let
			overrides = {
				snip = sources.snip // { call = {pkgs, path}: self.haskell.packages.ghc864.callPackage path {}; };
				passe = sources.passe // { call = { pkgs, path }: pkgs.callPackage path { target = "client"; }; };
				vim-watch = sources.vim-watch // { call = { pkgs, path }: pkgs.callPackage path { enableNeovim = true; }; };
			};
		in (sources // overrides));
	};

	wrangleAttrs = wrangleApi.importFrom args;
	overlay = foldr composeExtensions (_: _: {}) (wrangleApi.overlays args);
	packageImpls = overlay self super;

	# overlayObject is actually equal to packageImpls, but it delays the evaluation of the
	# actual package imports since its attribute names can be compued up front.
	# See https://discourse.nixos.org/t/cant-reference-any-attributes-of-super-in-toplevel-of-overlay/2704
	overlayObject = mapAttrs (name: _: builtins.getAttr name packageImpls) (wrangleAttrs.sources);
	injectOnlyNames = [ "opam2nix" "opam2nixBin"];
	installNames = (filter (x: !(elem x injectOnlyNames)) (attrNames wrangleAttrs.sources));
in
overlayObject // {
	installedPackages = (super.installedPackages or []) ++ (
		map (name: builtins.getAttr name self) installNames
	);
}
