with builtins;
let
	maybeImport = p: if pathExists p then [import p] else [];
in
import <nixpkgs> {
	overlays = [
		(import ./system.nix)
		(import ./overlay.nix)
	]
		++ (maybeImport ./overlay-local.nix)
		++ (maybeImport (./. + "host-${getEnv "HOSTNAME"}.nix"))
	;
}
