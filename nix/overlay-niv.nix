{ pkgs }:
self: super:
with super.lib;
let
	loadSources = sourcesFile:
		import ./sources.nix { inherit pkgs sourcesFile; };
	sources = loadSources ./sources.json;
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

in
{
	inherit sources loadSources;
	inherit nix-wrangle asdf-vm;
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
}
