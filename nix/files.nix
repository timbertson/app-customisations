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
	])) // {
		".vim" = symlink ../vim;
		".vimrc" = symlink ../vim/vimrc;
		".bin" = symlink ../bin;
		"dev/projects.gup" = symlink ../home/dev/projects.gup;
		".config/nixpkgs/config.nix" = symlink ./shared/config.nix;
		".config/nixpkgs/overlays/site.nix" = symlink ./shared/overlay-user.nix;
		".config/direnv-std" = symlink ../home/direnv-std;
		".config/direnvrc" = symlink ../home/direnv-std/direnvrc;
		".config/fish/functions" = symlink ../home/fish/functions;
		".config/fish/config.fish" = symlink ../home/fish/config.fish;
		".snip" = symlink ../home/snip;
		".gitconfig" = symlink ../home/git/config;
		".gitignore" = symlink ../home/git/ignore;
		".local/nix" = symlinkOpt ./home/home-path; # TODO if we rename home/ back to local/ ...
	}
	// (if pkgs.stdenv.isLinux then {
		".config/fontconfig/fonts.conf" = symlink ../home/fonts.conf;
		".xbindkeysrc.scm" = symlink ../home/xbindkeysrc.scm;
		".config/autostart/rhythmbox.desktop" = symlinkOpt /usr/share/applications/rhythmbox.desktop;
	} else {})

	// (if pkgs.stdenv.isDarwin then {
		"Library/KeyBindings/DefaultKeyBinding.dict" = symlink ../home/DefaultKeyBinding.dict;
	} else {});
}

#~/.config/autostart/desktop.desktop:
#  path: ../nix/local/share/applications/desktop-session.desktop
#  optional: true
#  tags: desktop

