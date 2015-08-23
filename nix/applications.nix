{pkgs ? import <nixpkgs> {}}:
with pkgs;
let
	apps = [
		# {
		# 	name = "Skype";
		# 	exec = "${skype}/bin/skype";
		# 	filename = "skype";
		# }
		# {
		# 	exec = "${spotify}/bin/spotify";
		# 	name = "Spotify";
		# 	filename = "spotify";
		# }
		# {
		# 	exec = "${calibre}/bin/calibre";
		# 	name = "Calibre";
		# 	filename = "calibre";
		# }
	];
in
stdenv.mkDerivation {
	name = "desktop-files";
	unpackPhase = "true";
	buildPhase = "true";
	installPhase = with lib; ''
		mkdir "$out"
		cd "$out"
		${
			concatStringsSep "\n" (map ({name, exec, filename ? null}:
				''
				cat > "${if filename == null then name else filename}.desktop" <<"EOF"
[Desktop Entry]
Version=1.0
Name=${name}
GenericName=${name}
Exec=${exec}
Terminal=false
Type=Application
Icon=${name}
EOF
				''
			) apps)
		}
	'';
}
