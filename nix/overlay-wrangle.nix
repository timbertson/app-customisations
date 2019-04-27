self: super:
with super.lib;
let
	wrangle = super.nix-wrangle.api {};
	callArgs = a: { pkgs, path }: pkgs.callPackage path args;
	callWith = fn: { pkgs, path }: fn path {};

	toSources = sources:
		let tryLocal = name: { path, ref ? "HEAD", nix ? "nix/", call ? null }:
			let concretePath = replaceStrings ["~"] [(builtins.getEnv "HOME")] path; in
			if builtins.pathExists concretePath then ({
				source = ["git-local" {
					inherit ref;
					path = concretePath;
				}];
				inherit nix;
			} // (if call == null then {} else { inherit call; }))
			else null;
		in
		{
			wrangle.apiversion = 1;
			sources = filterAttrs (n: v: v != null) (mapAttrs tryLocal sources);
		}
	;

	installedSources = toSources {
		gup-ocaml = { path = "~/dev/ocaml/gup"; nix = "nix/gup-ocaml.nix"; };
		music-import = { path = "~/dev/python/music-import"; nix = "nix/local.nix"; };
		dconf-user-overrides = { path = "~/dev/python/dconf-user-overrides"; nix = "nix/"; };
		# dumbattr = { path = "~/dev/python/dumbattr"; nix = "nix/local.nix"; };
		# eog-rate = { path = "~/dev/python/eog-rate"; nix = "nix/local.nix"; };
		git-wip = { path = "~/dev/python/git-wip"; nix = "nix/default.nix"; };
		irank = { path = "~/dev/python/irank"; nix = "default.nix"; };
		passe = { path = "~/dev/ocaml/passe"; nix = "nix/default.nix";
			call = { pkgs, path }: pkgs.callPackage path { target = "client"; }; ref = "wrangle"; };
		snip = { path = "~/dev/haskell/snip"; nix = "nix/default.nix"; call = callWith self.haskell.packages.ghc864.callPackage; };
		stereoscoper = { path = "~/dev/python/stereoscoper"; nix = "default.nix"; };
		trash = { path = "~/dev/python/trash"; nix = "default.nix"; };
		vim-watch = { path = "~/dev/vim/vim-watch"; nix = "nix/local.nix";
			call = { pkgs, path }: pkgs.callPackage path { enableNeovim = true; }; };
	};
	availableSources = toSources {
		opam2nix = { path = "~/dev/ocaml/opam2nix-packages"; nix = "nix/default.nix"; };
		opam2nixBin = { path = "~/dev/ocaml/opam2nix"; nix = "nix/default.nix"; };
	};
	args = {
		sources = [ availableSources installedSources ];
	};
	wrangleAttrs = wrangle.importFrom args;
	overlay = foldr composeExtensions (_: _: {}) (wrangle.overlays args);
	packageImpls = overlay self super;

	# overlayObject is actually equal to packageImpls, but it delays the evaluation of the
	# actual package imports since its attribute names can be compued up front.
	# See https://discourse.nixos.org/t/cant-reference-any-attributes-of-super-in-toplevel-of-overlay/2704
	overlayObject = mapAttrs (name: _: builtins.getAttr name packageImpls) (availableSources.sources // installedSources.sources);
in
overlayObject // {
	installedPackages = (super.installedPackages or []) ++ (
		map (name: builtins.getAttr name self) (attrNames installedSources.sources)
	);
}
