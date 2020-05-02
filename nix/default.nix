with builtins;
let
	hostname = if pathExists "/etc/hostname"
		then replaceStrings ["\n"] [""] (readFile "/etc/hostname")
		else "unknown";

	maybeImport = p: if pathExists p
		then trace "Including optional overlay: ${toString p}" [(import p)]
		else trace "Ignoring optional overlay: ${toString p}" [];

in
(import ./nixpkgs.nix).system {
	config = (import ./config.nix);
	overlays = [
		(self: super: { inherit hostname; })
		(import ./overlay-user.nix) # shared with ~/.config/nixpkgs/overlays/site.nix
		(import ./overlay-features.nix) # setup feature API
		(import ./overlay.nix) # base layer
		(import ./overlay-wrangle.nix) # wrangle sources
		(import ./overlay-home.nix) # home-manager
		(import ./overlay-symlinks.nix) # moar links
	]
		++ (maybeImport ./overlay-local.nix)
		++ (maybeImport (./. + "/host-${hostname}.nix"))
	;
}
