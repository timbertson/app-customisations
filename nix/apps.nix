{ pkgs }:
with pkgs;
with import ./session-vars.nix;
let
	loadSessionVars = "eval \"$(session-vars --all --process gnome-session --export)\"";
	mkDesktopDrv = { name, exec, filename ? null }:
		stdenv.mkDerivation {
			name = "desktop-files";
			buildCommand = with super.lib; ''
				mkdir -p "$out/share/applications"
				cd "$out/share/applications"
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
			'';
		};
in
{
	calibre = mkDesktopDrv {
		exec = "${calibre}/bin/calibre";
		name = "Calibre";
		filename = "calibre";
	};

	tilda-launch = mkDesktopDrv {
		exec = writeScript "tilda-launch" ''#!${pkgs.bash}/bin/bash
			${loadSessionVars}
			export GTK_THEME='Adwaita:dark'
			export TERM_SOLARIZED=1
			exec ${pkgs.tilda}/bin/tilda
			'';
		name = "Tilda";
		filename = "tilda";
	};

	my-desktop-session = mkDesktopDrv {
		exec = pkgs.writeScript "desktop-session" ''#!${pkgs.bash}/bin/bash
			reset-input &
			systemctl --user start desktop-session.target &
		'';
		name = "My desktop session";
		filename = "desktop-session";
	};
}
