self: super:
{
	features = super.features // {
		vim-ide = true;
		jdk = true;
	};
	installedPackages = super.installedPackages ++ (with self; [
		google-cloud-sdk
		chefdk
		jq
		pstree
	]);
}
