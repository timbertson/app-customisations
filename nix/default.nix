{ pkgs ? import <nixpkgs> {} }:
with builtins;
let
	etc-hostname = if pathExists "/etc/hostname"
		then replaceStrings ["\n"] [""] (readFile "/etc/hostname")
		else "unknown";

	maybeImport = p: if pathExists p
		then trace "Including optional overlay: ${toString p}" [(import p)]
		else trace "Ignoring optional overlay: ${toString p}" [];

in
(import pkgs.path) {
	config = (import ./shared/config.nix);
	overlays = [
		(self: super: { inherit etc-hostname; })
		(import ./shared/overlay-user.nix)
		(import ./overlay-features.nix)
		(import ./overlay-base.nix)
		(import ./overlay-niv.nix {inherit pkgs;})
		(import ./overlay-home.nix)
	]
		++ (maybeImport ./overlay-local.nix)
		++ (maybeImport (./. + "/host-${etc-hostname}.nix"))
	;
}
