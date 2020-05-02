{ pkgs, ... }:
with pkgs;
with pkgs.siteLib;
with lib;
let
	literalLink = path: pkgs.runCommand "link" {} ''
		ln -s '${path}' $out
	'';
in
{
	manual.manpages.enable = false;
	home = {
		packages = with pkgs; [
			git-wip
		];
		file = {
			"tim-test".text = ''
				hello!
			'';
			"tim-test2".source = literalLink "/tmp/gd";
		};
	};

	# programs.emacs = {
	#		enable = true;
	#		extraPackages = epkgs: [
	#			epkgs.nix-mode
	#			epkgs.magit
	#		];
	# };
	#
	# programs.firefox = {
	#		enable = true;
	#		enableIcedTea = true;
	# };
	#
	# services.gpg-agent = {
	#		enable = true;
	#		defaultCacheTtl = 1800;
	#		enableSshSupport = true;
	# };

	# programs.home-manager = {
	#		enable = true;
	#		# path = "…";
	# };
}
