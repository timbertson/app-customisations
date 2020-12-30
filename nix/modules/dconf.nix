{ pkgs, config, lib, ... }: {
	dconf.settings = {
		# focus follows mouse, change active window immediately
		"org.gnome.desktop.wm.preferences".focus-mode = "sloppy";
		"org.gnome.shell.overrides".focus-change-on-pointer-rest = false;

		# keybindings
		"org.gnome.desktop.wm.keybindings".close = ["<Shift><Super>c"];
		"org.gnome.desktop.input-sources".xkb-options = [
			"caps:ctrl_modifier" # capslock is extra ctrl key
			"ctrl:swap_lalt_lctl_lwin" # alt => ctrl, ctrl => win, win => Alt
		];
	};
}

