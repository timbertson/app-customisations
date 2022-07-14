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
	gup-ocaml = callPackage "${localHead ../../ocaml/gup}/nix" {
		inherit (self) opam2nix;
	};
	vdoml = callPackage "${localHead ../../ocaml/vdoml}/nix" {
		inherit (self) opam2nix;
	};
	remocaml = callPackage "${localHead ../../ocaml/passe}/nix" {
		inherit (self) opam2nix;
	};
	my-borg = callPackage (localHead ../../python/my-borg) {};

	# override default sources for globally installed packages
	installedPackages = (super.installedPackages or []) ++ [
		# only built for this machine
		(callPackage (localHead ../../python/irank) {})
		(let src = localHead ../../python/music-import; in
			callPackage ("${src}/nix") {} { inherit src; })
		(callPackage (localHead ../../python/trash) {})
		(callPackage "${localHead ../../ocaml/passe}/nix" {
			inherit (self) opam2nix;
		})
		self.remocaml
		self.my-borg
	];
}

