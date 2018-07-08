{ pkgs ? import <nixpkgs> {}}:
with pkgs;
let
		src = fetchgit {
			"url" = "https://github.com/timbertson/opam2nix-packages.git";
			"fetchSubmodules" = true;
			"sha256" = "1scjwdd6w5j1ab49hkcdg1xwx4p8l2gcp11jy86h2379aii46lxn";
			"rev" = "745ab033492872e7a2da04adacdc570819fba39d";
		};
		opam2nixSrc = fetchgit {
			"url" = "https://github.com/timbertson/opam2nix.git";
			"fetchSubmodules" = true;
			"sha256" = "1cmmghswq0ld1hqs2as0yz4w28iwy794nv66cxzqyf87wa7vc3aq";
			"rev" = "155606f5430e97e2f7062befcd7534cca4245631";
		};
	in
	callPackage "${src}/nix" {
		opam2nixBin = callPackage "${opam2nixSrc}/nix" {};
	}
