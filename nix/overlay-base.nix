self: super:
with builtins;
with super.lib;
with self.siteLib;
let
	lib = super.lib;
	stdenv = self.stdenv;
	callPackage = self.callPackage;

	sessionVars = import ./session-vars.nix;
	home = sessionVars.home;
	loadSessionVars = sessionVars.loadSessionVars;

	pkgs = self;

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

in {
	fish = if super.glibcLocales == null then super.fish else lib.overrideDerivation super.fish (o: {
		# workaround for https://github.com/NixOS/nixpkgs/issues/39328
		buildInputs = o.buildInputs ++ [ self.makeWrapper ];
		postInstall = ''
			wrapProgram $out/bin/fish --set LOCALE_ARCHIVE ${self.glibcLocales}/lib/locale/locale-archive
		'';
	});
	irank-releases = if self ? irank then (callPackage ({ lib, stdenv, makeWrapper, python3Packages, irank }:
		let
			pythonDeps = [ irank ] ++ (with python3Packages; [ musicbrainzngs pyyaml ]);
			pythonpath = lib.concatStringsSep ":" (map (dep: "${dep}/lib/${python3Packages.python.libPrefix}/site-packages") pythonDeps);
		in
		stdenv.mkDerivation {
			name = "irank-releases";
			buildInputs = [ makeWrapper ];
			shellHook = ''
				export PYTHONPATH="${pythonpath}"
			'';
			buildCommand =
				''
					mkdir -p "$out/bin"
					makeWrapper ${../bin/irank-releases.py} "$out/bin/irank-releases" \
						--prefix PYTHONPATH : ${pythonpath} \
						;
				'';
		}) {}) else null;

	my-borg-task = callPackage ({ pkgs }:
		with pkgs;
		let
			exe = "${home}/dev/python/my-borg/bin/my-borg";
			script = writeScript "my-borg-task" ''#!${pkgs.bash}/bin/bash
				set -eux
				${exe} --user=tim --status-file=backup backup
				${exe} --user=tim --status-file=sync sync
				${exe} --user=tim --status-file=check check
			'';
		in
		stdenv.mkDerivation {
			name = "my-borg-task";
			buildInputs = [ makeWrapper];
			buildCommand = ''
				mkdir -p $out/bin
				ln -s ${borgbackup}/bin/borg $out/bin/borg
				ln -s ${rclone}/bin/rclone $out/bin/rclone
				makeWrapper ${script} $out/bin/my-borg-task \
					--set PYTHONUNBUFFERED 1 \
					--prefix PATH : ${pkgs.python3}/bin \
					--prefix PATH : $out/bin \
					;
				makeWrapper ${exe} $out/bin/my-borg \
					--prefix PATH : ${pkgs.python3}/bin \
					--prefix PATH : $out/bin \
					;
			'';
		}) {};

	# TODO move to files.nix instead?
	my-gnome-shell-extensions =
		let exts = {
			"scroll-workspaces@gfxmonk.net" = "${home}/dev/gnome-shell/scroll-workspaces";
			"impatience@gfxmonk.net" = "${home}/dev/gnome-shell/impatience@gfxmonk.net";
		}; in (pkgs.runCommand "gnome-shell-extensions" {} ''
		mkdir -p $out/share/gnome-shell/extensions
		${concatStringsSep "\n" (remove null (mapAttrsToList (name: src:
			if src == null then null else ''
				for suff in xdg/data/gnome-shell/extensions share/gnome-shell/extensions; do
					if [ -e "${src}/$suff/${name}" ]; then
						ln -s "${src}/$suff/${name}" $out/share/gnome-shell/extensions/${name}
					else
						echo "Skipping non-existent gnome-shell extension: ${src}/$suff/${name}"
					fi
				done
			'') exts))
		}
	'');

	my-caenv = callPackage ./caenv.nix {};

	pyperclip-bin = callPackage ({ stdenv, python3Packages, which, xsel }:
		stdenv.mkDerivation {
			name = "pyperclip-bin";
			buildCommand = ''
				mkdir -p $out/bin
				cat > $out/bin/pyperclip << EOF
#!/usr/bin/env bash
export PATH="''${PATH:+\$PATH:}${lib.concatMapStringsSep ":" (p: "${p}/bin") [python3Packages.python which xsel]}"
export PYTHONPATH="${python3Packages.pyperclip}/${python3Packages.python.sitePackages}"
exec python3 -m pyperclip "\$@"
EOF
				chmod +x $out/bin/pyperclip
			'';
		}
	) {};

	# Make a consistent path for setting $QT_QPA_PLATFORM_PLUGIN_PATH
	# (see https://github.com/NixOS/nixpkgs/issues/24256)
	my-qt5 = stdenv.mkDerivation {
		name = "my-qt5";
		buildCommand = ''
			mkdir -p "$out/lib/qt5"
			ln -s ${self.qt5.qtbase.bin}/lib/qt-5*/plugins "$out/lib/qt5/plugins"
		'';
	};

	neovim = callPackage ./vim.nix {};
	ocaml-language-server = (pkgs.runCommand "ocaml-language-server" {} ''
		mkdir -p $out/bin
		ln -s "${pkgs.nodePackages.ocaml-language-server}/bin/ocaml-language-server" "$out/bin"
	'');
	python3Packages = super.python3Packages // {
		python-language-server = super.python3Packages.python-language-server.override { providers = []; };
	};
	vimPlugins = (callPackage ./vim-plugins.nix {}) // super.vimPlugins;

	my-desktop-session = mkDesktopDrv {
		exec = pkgs.writeScript "desktop-session" ''#!${pkgs.bash}/bin/bash
			reset-input &
			systemctl --user start desktop-session.target &
		'';
		name = "My desktop session";
		filename = "desktop-session";
	};
}
