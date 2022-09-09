self: super:
let
	zen = super.callPackage (builtins.fetchGit {
		url = "git@github.com:zendesk/zendesk-nix.git";
		ref = "HEAD";
		rev = "8f136bd7f22844a147815e4c8436c49b44f50fac";
	}) {};

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
	] ++ zen.all);
}
