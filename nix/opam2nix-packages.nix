{ pkgs ? import <nixpkgs> {}}:
with pkgs;
let
	src = fetchgit {
		fetchSubmodules = false;
		url = "https://github.com/gfxmonk/opam2nix-packages.git";
		rev = "23660412dde1e1c489e331da7d24abb7a325c260";
		sha256 = "a25f26858c8b99cd69ff90c98e60f2ae24866cf115c23763ad87816b87f210b6";
	};

	# We could leave this out and just use `fetchSubmodules` above,
	# but that leads to mass-rebuilds every time the repo changes
	# (rather than only when opam2nix is updated)
	opam2nix = fetchgit {
		url = "https://github.com/gfxmonk/opam2nix.git";
		rev = "b7376dc78aef9bb21a3a15dac8193b80fc81def4";
		sha256 = "97906e56dbd45706dc7c31879b3fa39cf43a88a935bf3384a2245cac07a9c721";
	};
in
callPackage "${src}/nix" {} { inherit src opam2nix; }
