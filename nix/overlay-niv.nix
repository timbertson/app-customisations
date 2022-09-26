{ pkgs }:
self: super:
with super.lib;
let
	baseSources = import ./sources.nix { inherit pkgs; };

	sources = self.sources;
	callPackage = self.callPackage;

	asdf-vm = self.stdenv.mkDerivation {
		name = "asdf-vm";
		src = sources.asdf;
		buildInputs = [ pkgs.makeWrapper ];
		installPhase = ''
			mkdir -p $out/share $out/bin
			cp -a . $out/share/asdf
			makeWrapper $out/share/asdf/bin/asdf $out/bin/asdf
		'';
	};

	fetlock = callPackage self.sources.fetlock {};

	localHead = p: trace "fetching ${builtins.toString p}" (builtins.fetchGit {
		url = p;
		ref = "HEAD";
	});

	# xremap = self.fetlock.cargo.load ./lock/xremap.nix {
	# 	pkgOverrides = api: [
	# 		(api.overrideSpec {
	# 			xremap = base: base // { features = [ "gnome" ]; };
	# 		})
	# 		(api.overrideAttrs {
	# 			bitvec = base: {
	# 				# https://github.com/bitvecto-rs/bitvec/pull/162
	# 				src = builtins.fetchGit {
	# 					url = "https://github.com/bitvecto-rs/bitvec.git";
	# 					rev = "8dcc6e96f012daade242318645d97487e59fbe6d";
	# 				};
	# 			};
	# 		})
	# 	];
	# };

in
{
	inherit asdf-vm localHead fetlock;
	sources = baseSources;
	installedPackages = (super.installedPackages or []) ++ [
		fetlock
		(callPackage sources.daglink {})
		(callPackage "${sources.git-wip}/nix" {})
		(callPackage sources.git-wip {})
		(callPackage "${sources.piep}/nix" {})
		(callPackage sources.status-check {})
		(callPackage "${sources.version-py}/nix" {})
		(callPackage "${sources.vim-watch}/nix" {})
		(callPackage sources.niv-util {}).cli
	];
	nixGL = callPackage sources.nixGL {};
	vim-sleuth-src = sources.vim-sleuth;
	home-manager-src = sources.home-manager;
	opam2nix = callPackage sources.opam2nix {};
	status-check = callPackage sources.status-check {};
}
