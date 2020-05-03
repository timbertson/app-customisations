self: super:
with super; {
	# disable fancy language server rubbish
	python3Packages = super.python3Packages // {
		python-language-server = super.python3Packages.python-language-server.override { providers = []; };
	};
}
