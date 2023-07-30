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
	sources = super.sources // {
		fetlock = localHead ../../rust/fetlock;
	};

	installedPackages = (super.installedPackages or []) ++ [
		# only built for this machine
		(callPackage (localHead ../../python/irank) {})
		(let src = localHead ../../python/music-import; in
			callPackage ("${src}/nix") {} { inherit src; })
		(callPackage (localHead ../../python/trash) {})

		(let src = localHead ../../ocaml/passe; in callPackage "${src}/nix" {
			inherit (self) opam2nix vdoml;
			self = src;
		})
		self.my-borg
		self.borgmatic
		self.python3Packages.twine
		self.remocaml
	];
}

