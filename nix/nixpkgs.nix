let
	system = import /nix/var/nix/profiles/per-user/tim/channels-44-link/nixpkgs;
in {
	inherit system;
	pinned =
		let sys = system {};
		in import (sys.fetchFromGitHub
			(sys.lib.importJSON ./nix/wrangle.json).sources.pkgs.fetch);
}
