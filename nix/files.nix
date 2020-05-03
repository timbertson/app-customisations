# logically belongs in modules/, but this prevents extra `../` everywhere
{ pkgs, config, lib, ... }:
with pkgs.siteLib;
with lib;
let
	# TODO: replace daglink
	symlinkOpt = source:
		if builtins.pathExists source then {
		source = pkgs.runCommand "link" {} ''
		ln -s '${toString source}' $out
	'';
	} else null;

	symlink = source:
		let ret = symlinkOpt source; in
		if ret == null
			then (abort "file does not exist: ${toString source}")
			else ret;
	always = nameValuePair;
	feature = feat: target: source: ifEnabled feat { name = target; value = { inherit source; }; };
in
{
	home.file = (listToAttrs (remove null [
		(feature "maximal" ".config/autostart/tilda.desktop" "${pkgs.tilda-launch}/share/applications/tilda.desktop")
	])) // {
		".vim" = symlink ../vim;
		".vimrc" = symlink ../vim/vimrc;
		".bin" = symlink ../bin;
		"dev/projects.gup" = symlink ../home/dev/projects.gup;
		".config/nixpkgs/config.nix" = symlink ./shared/config.nix;
		".config/nixpkgs/overlays/site.nix" = symlink ./shared/overlay-user.nix;
	};
}

#/etc/security/pam.env.conf:
#  path: ../root/pam/environment.conf
#  tags: linux root
#
#/etc/gdm/env.d/nix-xdg.env:
#  path: ../root/gdm/env.d/xdg-nix.env
#  tags: linux root nix
#
#~/.config/direnv-std:
#  path: ../home/direnv-std
#
#~/.direnvrc:
#  path: ../home/direnv-std/direnvrc
#
#~/.gconf/apps/gnome-terminal:
#  path: ../home/gconf/apps/gnome-terminal
#  tags: desktop
#
#~/.gconf/apps/metacity/general/%gconf.xml:
#  path: ../home/gconf/apps/metacity/general/%gconf.xml
#  tags: desktop
#
#~/.gconf/apps/metacity/window_keybindings/%gconf.xml:
#  path: ../home/gconf/apps/metacity/window_keybindings/%gconf.xml
#  tags: desktop
#
#~/.gconf/desktop/gnome/shell/windows/%gconf.xml:
#  path: ../home/gconf/desktop/gnome/shell/windows/%gconf.xml
#  tags: desktop
#
#~/.icons:
#  path: ../home/icons
#  tags: linux
#
#~/.cwiid:
#  path: ../home/cwiid
#  tags: linux
#
#~/.config/fontconfig/fonts.conf:
#  path: ../home/fonts.conf
#  tags: linux
#
#~/.config/fish/functions:
#  path: ../home/fish/functions
#  tags: fish
#
#~/.config/fish/config.fish:
#  path: ../home/fish/config.fish
#  tags: fish
#
#~/.inputrc:
#  path: ../home/inputrc
#  tags: linux
#
#~/.tmux.conf:
#  path: ../home/tmux.conf
#
#~/.ctags:
#  path: ../home/ctags
#
#~/.xbindkeysrc.scm:
#  - path: ../home/xbindkeysrc.scm
#    tags: linux
#  - path: ../home/xbindkeysrc-tv.scm
#    tags: tv
#
#~/.bashrc:
#  path: ../home/bashrc
#  tags: linux
#
#~/.snip:
#  path: ../home/snip
#
#~/.gitconfig:
#  path: ../home/git/config
#
#~/.gitignore:
#  path: ../home/git/ignore
#
#~/.git/hooks:
#  path: ../home/git/hooks
#
#~/.config/rygel.conf:
#  path: ../home/rygel.conf
#  tags: linux
#
### multi-user
#~/users/www-browser/.themes:
# path: /home/tim/.local/share/themes
# tags: multi-user linux
#
#~/users/www-browser/.config/fontconfig:
# path: /home/tim/.config/fontconfig
# tags: multi-user linux
#
#~/users/www-browser/Desktop:
# path: /home/tim/Desktop
# tags: multi-user linux
#
#~/users/www-browser/Downloads:
# path: /home/tim/Downloads
# tags: multi-user linux
#
### KEYBOARD TYPES
#~/.xkb:
#  path: ../home/xkb-mac
#  tags: mac-kb fedora xkb
#
#/bin/reset-xkb:
#  path: ../bin/reset-xkb
#  tags: mac-kb fedora xkb
#
#~/.config/dconf.user.d/disable-gnome-xkb:
#  path: ../home/dconf/disable-gnome-xkb
#  tags: mac-kb fedora xkb
#
#~/.config/dconf.user.d/xkb-mac:
#  path: ../home/dconf/xkb-mac
#  tags: mac-kb linux xkb
#
#~/.config/dconf.user.d/focus-follows-mouse:
#  path: ../home/dconf/focus-follows-mouse
#  tags: linux
#
#~/.config/dconf.user.d/immediate-focus:
#  path: ../home/dconf/immediate-focus
#  tags: linux
#
#~/.config/dconf.user.d/disable-housekeeping-plugin:
#  path: ../home/dconf/disable-housekeeping-plugin
#  tags: linux
#
#~/.config/dconf.user.d/shellshape:
#  path: ../home/dconf/shellshape
#  tags: linux shellshape
#
##TODO: make a pc xkb config
#
#~/.xmodmaprc:
#  - path: ../home/xmodmaprc-mac
#    tags: mac-kb xmodmap
#  - path: ../home/xmodmaprc-pc
#    tags: pc xmodmap
#
### apps:
##~/.config/autostart/banshee.desktop:
##  - path: /usr/share/applications/banshee.desktop
##    tags: desktop
#
#~/.config/autostart/rhythmbox.desktop:
#  - path: /usr/share/applications/rhythmbox.desktop
#    tags: fedora desktop
#
#~/.config/autostart/desktop.desktop:
#  path: ../nix/local/share/applications/desktop-session.desktop
#  optional: true
#  tags: desktop
#
#~/.config/nixpkgs/config.nix:
#  path: ../nix/config.nix
#  tags: nix
#
#~/.config/nixpkgs/overlays/site.nix:
#  path: ../nix/overlay-user.nix
#  tags: nix
#
#~/.local/nix:
#  path: ../nix/local
#  optional: true
#  tags: nix
#
#~/.config/systemd/user:
#  path: ../nix/local/share/systemd/user
#  optional: true
#  tags: nix systemd
#
#/etc/systemd/system/multi-user.target.wants/borg.timer:
#  optional: true
#  path: /etc/systemd/system/borg.timer
#  tags: systemd
#
#~/.local/share/applications/calibre.desktop:
#  path: ../home/applications/nix/calibre.desktop
#  optional: true
#  tags: desktop nix
#
#~/.local/share/applications/skype.desktop:
#  path: ../nix/local/share/applications/skype.desktop
#  optional: true
#  tags: desktop nix
#
#/nix/var/nix/gcroots/tim-nix-local:
#  path: ../nix/local
#  optional: true
#  tags: nix
#
#/etc/nix/nix.conf:
#  path: ../root/nix/nix.conf
#  tags: nix root
#
### LINUX
#
#/etc/yum.repos.d/google-chrome.repo:
#  path: ../root/yum.repos.d/google-chrome.repo
#  tags: fedora root
#
## /usr/lib/systemd/system-sleep/apply-xkb:
##   path: ../root/systemd/apply-xkb
##   tags: fedora root xkb
#
## note: hardware specific
#/usr/lib/systemd/system-sleep/reset-ehci-driver:
#  path: ../root/systemd/reset-ehci-driver
#  tags: fedora root meep
#
#/etc/selinux/config:
#  path: ../root/selinux/config
#  tags: linux root
#
### OSX
#
#~/Library/KeyBindings/DefaultKeyBinding.dict:
#  path: ../osx/DefaultKeyBinding.dict
#  tags: osx
#
