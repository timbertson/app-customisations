self: super:
with super; {
	python3Packages = super.python3Packages // {
		json-schema-for-humans = pkgs.poetry2nix.mkPoetryApplication rec {
			src = super.fetchFromGitHub {
				owner = "coveooss";
				repo = "json-schema-for-humans";
				rev = "v0.39.1";
				sha256 = "0pwzc0gaf2w8a03qx56v79dzmlw032rx16im44dw0ln88xfgi016";
			};
			projectDir = src;
		};
	};
	sbt = super.sbt.override { jre = super.openjdk11; };
	scala = super.scala.override { jre = super.openjdk11; };
}
