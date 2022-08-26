self: super:
let
	zen = super.callPackage (builtins.fetchGit {
		url = "git@github.com:zendesk/zendesk-nix.git";
		ref = "HEAD";
		rev = "4b4112f6793e4fd5885cf1edb9002824707e0b71";
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
