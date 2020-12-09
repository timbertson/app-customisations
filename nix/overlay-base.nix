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
	fzf = super.fzf.overrideAttrs (o: {
		checkPhase = "true";
		# fzf installs some default keybindings that override my own
		installPhase = (o.installPhase or "") + ''
			rm -r $out/share/fish/vendor_conf.d
		'';
	});
	irank-releases = if self ? irank then (callPackage ({ lib, stdenv, makeWrapper, python3Packages}:
		let
			pythonDeps = with python3Packages; [ musicbrainzngs pyyaml ];
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

	my-borg-task = callPackage ({ pkgs, my-borg }:
		stdenv.mkDerivation {
			name = "my-borg-task";
			buildCommand =
				let exe = "${my-borg}/bin/my-borg"; in ''
				mkdir -p $out/bin
				echo > $out/bin/my-borg-task <<EOF
					#!${pkgs.bash}/bin/bash
					set -eux
					export PYTHONUNBUFFERED=1
					${exe} --user=tim --status-file=backup backup
					${exe} --user=tim --status-file=sync sync
					${exe} --user=tim --status-file=check check
EOF
				chmod +x $out/bin/my-borg-task
			'';
		}) {};

	my-caenv = callPackage ./caenv.nix {};

	my-jdks = with pkgs;
		stdenv.mkDerivation {
			name = "jdks";
			buildCommand = ''
				dest="$out/jdk"
				mkdir -p "$dest"
				ln -s "${openjdk}" "$dest/8"
				ln -s "${openjdk11}" "$dest/11"
			'';
		};

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

	neovim-nightly = callPackage ./vim.nix {
		neovim-unwrapped = super.neovim-unwrapped.overrideAttrs (o: {
			src = self.neovim-nightly-src;
			version = "0.5-nightly";
			buildInputs = o.buildInputs ++ (with self; [
				# unzip cmake
				# gettext
				pkgconfig
				tree-sitter
		]);
		});
	};

	vscode = super.vscode.overrideAttrs (o: {
		buildInputs = o.buildInputs ++ [ self.makeWrapper ];
		installPhase = o.installPhase + ''
			ln -s ${self.neovim-nightly}/bin/nvim $out/bin/nvim-nightly
		'';
	});

	python3Packages = super.python3Packages // {
		python-language-server = super.python3Packages.python-language-server.override { providers = []; };
	};
	vimPlugins = (callPackage ./vim-plugins.nix {}) // super.vimPlugins;

	my-desktop-session = mkDesktopDrv {
		# https://naftuli.wtf/2017/12/28/systemd-user-environment/
		exec = pkgs.writeScript "desktop-session" ''#!${pkgs.bash}/bin/bash
			set -eux
			systemctl --user import-environment
			systemctl --user start desktop-session.target
		'';
		name = "My desktop session";
		filename = "desktop-session";
	};
}
