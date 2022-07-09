self: super:
let
	zen = super.callPackage (builtins.fetchGit {
		url = "git@github.com:zendesk/zendesk-nix.git";
		ref = "HEAD";
		rev = "21b2c5bd6a0a4eb6be6190c5e0f435840d9794e9";
	}) {};

	localHead = p: super.lib.trace "fetching ${builtins.toString p}" (builtins.fetchGit {
		url = p;
		ref = "HEAD";
	});

in
{
	features = super.features // {
		vim-ide = true;
		jdk = true;
	};

	# override default sources
	sources = super.sources // {
		fetlock = localHead ../../rust/fetlock;
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
