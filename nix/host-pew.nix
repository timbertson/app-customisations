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
	vdoml = callPackage "${localHead ../../ocaml/vdoml}/nix" {
		inherit (self) opam2nix;
	};
	remocaml = (callPackage "${localHead ../../web/remocaml}/nix" {
		inherit (self) opam2nix;
	}).remocaml;
	my-borg = callPackage (localHead ../../python/my-borg) {};

	# override default sources for globally installed packages
	installedPackages = (super.installedPackages or []) ++ [
		# only built for this machine
		(callPackage (localHead ../../python/irank) {})
		(let src = localHead ../../python/music-import; in
			callPackage ("${src}/nix") {} { inherit src; })
		(callPackage (localHead ../../python/trash) {})

		# TODO
		# (callPackage "${localHead ../../ocaml/passe}/nix" {
		# 	inherit (self) opam2nix;
		# })
		self.my-borg
	];
}

