let
	system = import <nixpkgs>;
in {
	inherit system;
	pinned =
		let sys = system {};
		in import (sys.fetchFromGitHub
			(sys.lib.importJSON ./nix/wrangle.json).sources.pkgs.fetch);
}
