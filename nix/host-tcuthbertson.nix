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
	installedPackages = super.installedPackages ++ (with self; [
		gnupg
		vendir
		jsonnet
		stern
		asdf-vm
		super.vscode
		google-cloud-sdk
		chefdk
		jq
		pstree
	]) ++ (super.callPackage super.sources.zendesk-nix {}).all;
}
