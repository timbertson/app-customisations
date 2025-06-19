{ pkgs }:
self: super:
with super.lib;
let
	baseSources = import ./sources.nix { inherit pkgs; };

	nivSources = self.nivSources;
	callPackage = self.callPackage;

	asdf-vm = self.stdenv.mkDerivation {
		name = "asdf-vm";
		src = nivSources.asdf;
		buildInputs = [ pkgs.makeWrapper ];
		installPhase = ''
			mkdir -p $out/share $out/bin
			cp -a . $out/share/asdf
			makeWrapper $out/share/asdf/bin/asdf $out/bin/asdf
		'';
	};

	fetlock = callPackage self.nivSources.fetlock {};

	localHead = p: trace "fetching ${builtins.toString p}" (builtins.fetchGit {
		url = p;
		ref = "HEAD";
	});

	xremap = (self.fetlock.cargo.load ./lock/xremap.nix {
		pkgOverrides = api: [
			(api.overrideAttrs {
				bitvec = base: {
					# https://github.com/bitvecto-rs/bitvec/pull/162
					src = builtins.fetchGit {
						url = "https://github.com/bitvecto-rs/bitvec.git";
						rev = "8dcc6e96f012daade242318645d97487e59fbe6d";
					};
				};
			})
		];
	}).root;

	my-borg = callPackage nivSources.my-borg {};
	
	yt-dlp = super.yt-dlp.overrideAttrs (o: {
		version = "dev";
		src = nivSources.yt-dlp;
		# patches = []; # upstream patches are based on an old version
		# postInstall = ""; # skip insallShellCompletion
	});

in
{
	inherit asdf-vm localHead fetlock xremap my-borg yt-dlp;
	nivSources = baseSources;
	installedPackages = (super.installedPackages or []) ++ [
		fetlock
		(callPackage nivSources.daglink {})
		(callPackage "${nivSources.git-wip}/nix" {})
		(callPackage nivSources.git-wip {})
		(callPackage "${nivSources.piep}/nix" {})
		(callPackage nivSources.status-check {})
		(callPackage "${nivSources.version-py}/nix" {})
		(callPackage "${nivSources.vim-watch}/nix" {})
		(callPackage nivSources.niv-util {}).cli
	];

	nixGL = callPackage nivSources.nixGL {};
	vim-sleuth-src = nivSources.vim-sleuth;
	home-manager-src = nivSources.home-manager;
	paperwm = nivSources.PaperWM;
	opam2nix = callPackage nivSources.opam2nix {};
	status-check = callPackage nivSources.status-check {};

	# TODO remove after 2.36.1+
	my-direnv = super.pkgs.direnv.overrideAttrs (o: {
		src = nivSources.direnv;
		version = "development";
		vendorHash = "sha256-SAIGFQGACTB3Q0KnIdiKKNYY6fVjf/09wGqNr0Hkg+M=";
	});
}
