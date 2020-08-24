{ pkgs, nix-wrangle }:
with builtins;
let
	hostname = if pathExists "/etc/hostname"
		then replaceStrings ["\n"] [""] (readFile "/etc/hostname")
		else "unknown";

	maybeImport = p: if pathExists p
		then trace "Including optional overlay: ${toString p}" [(import p)]
		else trace "Ignoring optional overlay: ${toString p}" [];

in
(import pkgs.path) {
	config = (import ./shared/config.nix);
	overlays = [
		(self: super: { inherit hostname; })
		(import ./shared/overlay-user.nix)
		(import ./overlay-features.nix)
		(import ./overlay-base.nix)
		(import ./overlay-wrangle.nix {inherit pkgs nix-wrangle;})
		(import ./overlay-home.nix)
	]
		++ (maybeImport ./overlay-local.nix)
		++ (maybeImport (./. + "/host-${hostname}.nix"))
	;
}
