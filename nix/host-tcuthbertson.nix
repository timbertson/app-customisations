self: super:
let
	localHead = self.localHead;
	callPackage = super.callPackage;
in
{
	features = super.features // {
		vim-ide = true;
		jdk = true;
	};

	# override default sources for globally installed packages
	nivSources = super.nivSources // {
		fetlock = self.localHead ../../rust/fetlock;
	};

	# # temporary gup 0.8.1
	# gup = let src = self.localHead ../../timbertson/gup; in
	# 	(super.callPackage "${src}/nix/gup-python.nix" {}); #.overrideAttrs (orig: { src; });

	netproxrc = (callPackage "${localHead ../../timbertson/netproxrc}/nix" {}).root;

	installedPackages = super.installedPackages ++ (with self; [
		rbenv
		# bundler
		chef-cli
		fblog
		gnupg
		netproxrc
		vendir
		jsonnet
		stern
		asdf-vm
		super.vscode
		google-cloud-sdk
		jq
		pstree
	]) ++ (super.callPackage super.nivSources.zendesk-nix {}).all;
}
