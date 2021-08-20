self: super:
{
	features = super.features // {
		vim-ide = true;
		jdk = true;
	};
	installedPackages = super.installedPackages ++ (with self; [
		gnupg
		kubectl
		kubie
		awscli2
		saml2aws
		ssm-session-manager-plugin
		asdf-vm
		super.vscode
		google-cloud-sdk
		chefdk
		jq
		pstree
	]);
}
