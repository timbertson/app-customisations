{ pkgs, config, lib, ... }: {
	dconf.settings = {
		# focus follows mouse, change active window immediately
		"org.gnome.desktop.wm.preferences".focus-mode = "sloppy";
		"org.gnome.shell.overrides".focus-change-on-pointer-rest = false;

		# keybindings
		"org.gnome.desktop.wm.keybindings".close = ["<Shift><Super>c"];
	};
}

