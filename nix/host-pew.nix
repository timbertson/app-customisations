self: super:
{
	features = super.features // {
		maximal = true;
		systemd = true;
		vim-ide = true;
		jdk = true;
	};
	installedPackages = (super.installedPackages or []) ++ [
		# super.vscode
	];
}
