{ pkgs }:
self: super:
with super.lib;
let
	baseSources = import ./sources.nix { inherit pkgs; };

	sources = self.sources;
	callPackage = self.callPackage;

	# exported and installed
	nix-wrangle = callPackage "${sources.nix-wrangle}/nix" { self = sources.nix-wrangle; };

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

	localHead = p: trace "fetching ${builtins.toString p}" (builtins.fetchGit {
		url = p;
		ref = "HEAD";
	});

in
{
	inherit nix-wrangle asdf-vm localHead;
	sources = baseSources;
	installedPackages = (super.installedPackages or []) ++ [
		(callPackage sources.daglink {})
		(callPackage self.sources.fetlock {})
		(callPackage "${sources.git-wip}/nix" {})
		(callPackage sources.git-wip {})
		(callPackage "${sources.piep}/nix" {})
		(callPackage sources.status-check {})
		(callPackage "${sources.version-py}/nix" {})
		(callPackage "${sources.vim-watch}/nix" {})
		(callPackage sources.niv-util {}).cli
		nix-wrangle
	];
	nixGL = callPackage sources.nixGL {};
	vim-sleuth-src = sources.vim-sleuth;
	home-manager-src = sources.home-manager;
	opam2nix = callPackage sources.opam2nix {};
	status-check = callPackage sources.status-check {};
}
