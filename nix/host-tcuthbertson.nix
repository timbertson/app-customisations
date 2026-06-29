self: super:
let
	localHead = self.localHead;
	callPackage = super.callPackage;
	zendesk = super.callPackage super.nivSources.zendesk-nix {};
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
		# rbenv
		# bundler
		argo-workflows
		fblog
		gnupg
		gh
		netproxrc
		vendir
		jsonnet
		stern
		asdf-vm
		google-cloud-sdk
		jq
		yaml2json
		pstree
	]) ++ zendesk.all;

	inherit zendesk;
}
