with builtins;
let
	hostname = let
		fromEnv = getEnv "HOSTNAME";
		fromFile = if pathExists "/etc/hostname"
			then replaceStrings ["\n"] [""] (readFile "/etc/hostname")
			else "unknown";
	in if fromEnv == "" then fromFile else fromEnv;

	maybeImport = p: if pathExists p
		then trace "Including optional overlay: ${toString p}" [(import p)]
		else trace "Ignoring optional overlay: ${toString p}" [];

in
import <nixpkgs> {
	config = (import ./config.nix);
	overlays = [
		(self: super: { inherit hostname; })
		(import ./system.nix)
		(import ./overlay-user.nix)
		(import ./overlay.nix)
		(import ./overlay-wrangle.nix)
	]
		++ (maybeImport ./overlay-local.nix)
		++ (maybeImport (./. + "/host-${hostname}.nix"))
	;
}
