self: super:
{
	features = super.features // {
		maximal = true;
		systemd = true;
		vim-ide = true;
	};
}
