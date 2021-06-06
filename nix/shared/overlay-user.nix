self: super:
with super; {
	# disable fancy language server rubbish
	python3Packages = super.python3Packages // {
		python-language-server = super.python3Packages.python-language-server.override { providers = []; };
	};
	sbt = super.sbt.override { jre = super.openjdk11; };
	scala = super.scala.override { jre = super.openjdk11; };
}
