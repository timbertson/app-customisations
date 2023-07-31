# logically belongs in modules/, but this prevents extra `../` everywhere
{ pkgs, config, lib, ... }:
with pkgs.siteLib;
with lib;
let
	home = (import ./session-vars.nix).home;

	symlinkForce = source: {
		source = pkgs.runCommand "link" {} ''
			ln -s '${toString source}' $out
		'';
	};

	symlinkOpt = source:
		if builtins.pathExists source
			then symlinkForce source
			else null;


	symlink = source:
		let ret = symlinkOpt source; in
		if ret == null
			then (abort "file does not exist: ${toString source}")
			else ret;

	# feature = feat: target: source: ifEnabled feat { name = target; value = { inherit source; }; };
in
{
	home.file = filterAttrs (n: v: v != null) (
		{
			".vim" = symlink ../vim;
			".vimrc" = symlink ../vim/vimrc;
			".bin" = symlink ../bin;
			"dev/.projects.gup" = symlink ../home/dev/projects.gup;
			".config/nixpkgs/config.nix" = symlink ./shared/config.nix;
			".config/nixpkgs/overlays/site.nix" = symlink ./shared/overlay-user.nix;
			".config/direnv-std" = symlink ../home/direnv-std;
			".config/direnv/direnvrc" = symlink ../home/direnv-std/direnvrc;
			".config/fish/functions" = symlink ../home/fish/functions;
			".config/fish/config.fish" = symlink ../home/fish/config.fish;
			".snip" = symlink ../home/snip;
			".gitconfig" = symlink ../home/git/config;
			".gitignore" = symlink ../home/git/ignore;
			".local/nix" = symlinkOpt ./local/home-path;
		}
		// (if pkgs.stdenv.isLinux then {
			".config/fontconfig/fonts.conf" = symlink ../home/fonts.conf;
			".xbindkeysrc.scm" = symlink ../home/xbindkeysrc.scm;
			".config/borgmatic.d/01-main.yaml" = symlink ../home/borgmatic/main.yaml;
			".config/borgmatic.d/02-media.yaml" = symlink ../home/borgmatic/media.yaml;
			".config/autostart/rhythmbox.desktop" = symlinkOpt /usr/share/applications/rhythmbox.desktop;
			".local/share/gnome-shell/extensions/scroll-workspaces@gfxmonk.net" = symlinkOpt "${home}/dev/gnome-shell/scroll-workspaces/scroll-workspaces";
			".local/share/gnome-shell/extensions/impatience@gfxmonk.net" = symlinkOpt "${home}/dev/gnome-shell/impatience@gfxmonk.net/impatience";
			# ".local/share/gnome-shell/extensions/BringOutSubmenuOfPowerOffLogoutButton@pratap.fastmail.fm".source = "${pkgs.gnome-shell-rearrange-system-menu}";
			".config/autostart/start-desktop-session.desktop".text = (
				# https://naftuli.wtf/2017/12/28/systemd-user-environment/
				''
					[Desktop Entry]
					Version=1.0
					Name=My Desktop Session
					Exec=systemctl --user start desktop-session.target
					Terminal=false
					Type=Application
				''
			);
		} else {})

		// (if pkgs.stdenv.isDarwin then {
			"Library/KeyBindings/DefaultKeyBinding.dict" = symlink ../home/DefaultKeyBinding.dict;
		} else {})
	);
}
