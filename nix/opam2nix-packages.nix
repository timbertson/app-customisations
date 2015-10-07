{ pkgs ? import <nixpkgs> {}}:
with pkgs;
let
	src = fetchgit {
		fetchSubmodules = false;
		url = "https://github.com/gfxmonk/opam2nix-packages.git";
		rev = "7104f035c734171853ee38ccba4140c456d035c3";
		sha256 = "8da29a5753fd0fb338d1dae76887fa4d02232950104bf4e099d534b3ba56a0de";
	};

	# We could leave this out and just use `fetchSubmodules` above,
	# but that leads to mass-rebuilds every time the repo changes
	# (rather than only when opam2nix is updated)
	opam2nix = fetchgit {
		url = "https://github.com/gfxmonk/opam2nix.git";
		rev = "ea7bcfe04dbc625f38c00cc96ab8b4b7caac7ff4";
		sha256 = "2d893c8b748956cf13c69057f369721b7497b6da44f237733e4a48077907b9a3";
	};
in
callPackage "${src}/nix" {} { inherit src opam2nix; }
