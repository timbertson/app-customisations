
{ pkgs ? import <nixpkgs> {}}:
with pkgs;
let
	# For development, set OPAM2NIX_DEVEL to your local
	# opam2nix repo path
	devRepo = builtins.getEnv "OPAM2NIX_DEVEL";
	src = fetchgit 	{
		"url" = "https://github.com/timbertson/opam2nix-packages.git";
		"fetchSubmodules" = false;
		"sha256" = "15jx91aigg85gzyidpa4xabcniz86phqr3v248dnzvls8j448w50";
		"rev" = "65cd9e1ea26ada2367fd127304d3359c6c7643e0";
	};
	opam2nix = fetchgit 	{
		"url" = "https://github.com/timbertson/opam2nix.git";
		"fetchSubmodules" = false;
		"sha256" = "1xf7qhkd34dykx23hawmswla0b78s6g83y2mz74jh32ydg2x5i4g";
		"rev" = "ccd6f4d4f8afc1f515fce373c50df721d5a86a6c";
	};
in
if devRepo != "" then
	let toPath = s: /. + s; in
	callPackage "${devRepo}/nix" {} {
		src = toPath "${devRepo}/nix/local.tgz";
		opam2nix = let devSrc = "${devRepo}/opam2nix/nix/local.tgz"; in
			if builtins.pathExists devSrc then toPath devSrc else opam2nix;
	}
else callPackage "${src}/nix" {} { inherit src opam2nix; }
