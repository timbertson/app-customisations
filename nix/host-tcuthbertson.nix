self: super:
let

in
{
	features = super.features // {
		vim-ide = true;
		jdk = true;
	};

	# override default sources for globally installed packages
	sources = super.sources // {
		fetlock = self.localHead ../../rust/fetlock;
	};

	# # temporary gup 0.8.1
	# gup = let src = self.localHead ../../timbertson/gup; in
	# 	(super.callPackage "${src}/nix/gup-python.nix" {}); #.overrideAttrs (orig: { src; });

	installedPackages = super.installedPackages ++ (with self; [
		rbenv
		# bundler
		chef-cli
		fblog
		gnupg
		vendir
		jsonnet
		stern
		asdf-vm
		super.vscode
		google-cloud-sdk
		jq
		pstree
	]) ++ (super.callPackage super.sources.zendesk-nix {}).all;
}
