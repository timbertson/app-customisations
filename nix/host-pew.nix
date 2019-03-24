self: super: {
	features = super.features // {
		systemd = true;
		vim-ide = true;
		syncthing = true;
	};
}
