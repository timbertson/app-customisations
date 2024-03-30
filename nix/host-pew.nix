self: super:
let
	callPackage = super.callPackage;
	localHead = self.localHead;
in
{
	features = super.features // {
		maximal = true;
		systemd = true;
		vim-ide = true;
		jdk = true;
	};

	# these are exported for use in other modules
	gup-ocaml = let src = localHead ../../ocaml/gup; in
		callPackage "${src}/nix" {
			inherit (self) opam2nix;
			self = src;
		};
	vdoml = localHead ../../ocaml/vdoml;
	remocaml = (callPackage "${localHead ../../web/remocaml}/nix" {
		inherit (self) opam2nix vdoml;
	}).remocaml;
	my-borg = callPackage (localHead ../../python/my-borg) {};

	# override default sources for globally installed packages
	nivSources = super.nivSources // {
		fetlock = localHead ../../rust/fetlock;
	};

	borgmatic = super.borgmatic.overrideAttrs (upstream:
		if upstream.version == "1.7.15" then rec {
			version = "1.8.0";
			name = "${upstream.pname}-${version}";
			src = super.fetchPypi {
				inherit (upstream) pname;
				inherit version;
				sha256 = "tWHGnyQdnoevWFcgB56e97Q73ujUw5yHdUduBo7HGlo=";
			};
		} else (super.lib.warn "borgmatic override is no longer needed in host-pew.nix" {})
	);

	passe = (let src = localHead ../../ocaml/passe; in callPackage "${src}/nix" {
		inherit (self) opam2nix vdoml;
		self = src;
	});

	installedPackages = (super.installedPackages or []) ++ [
		# only built for this machine
		(callPackage (localHead ../../python/irank) {})
		(let src = localHead ../../python/music-import; in
			callPackage ("${src}/nix") {} { inherit src; })
		(callPackage (localHead ../../python/trash) {})

		self.passe
		self.my-borg
		self.borgmatic
		self.python3Packages.twine
		self.remocaml
	];
}

