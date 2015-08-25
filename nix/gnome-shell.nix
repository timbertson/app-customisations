{pkgs ? import <nixpkgs> {}}:
with pkgs;
let
	home = builtins.getEnv "HOME";
in
{
	"shellshape@gfxmonk.net" = pkgs.shellshape or null;
	"scroll-workspaces@gfxmonk.net" = "${home}/dev/gnome-shell/scroll-workspaces";
	"impatience@gfxmonk.net" = "${home}/dev/gnome-shell/impatience@gfxmonk.net";
}

