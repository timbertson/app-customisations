self: super:
with builtins;
with super.lib;
let
	defaultFeatures = {
		node = true;
		maximal = false;
		git-readonly = false;
		gnome-shell = false;
		jdk = false;
		systemd = false;
		vim-ide = false;
	};

	lib = super.lib;
	stdenv = self.stdenv;
	callPackage = self.callPackage;

	withExtantPath = p: fn:
		if (builtins.pathExists p)
			then fn (builtins.toPath p)
			else lib.warn "no such file: ${path}" null;

	firstNonNull = items:
		findFirst (x: x != null) null items;

	isEnabled = feature:
		if (!hasAttr feature defaultFeatures) then
			lib.warn "Unknown feature: ${feature}" (assert false; null)
		else getAttr feature self.features;

	orNull = cond: x: if cond then x else null;

	ifEnabled = feature: x: orNull (isEnabled feature) x;

	anyEnabled = features: x: orNull (any isEnabled features) x;

	home = (import ./session-vars.nix).home;
in
{
	features = defaultFeatures;
	siteLib = {
		inherit
			isEnabled
		;
	};

	installedDerivations = map (o: o.drvPath) self.installedPackages;

	installedPackages = with self; builtins.trace "Features: ${builtins.toJSON self.features}" (let
		maximal = ifEnabled "maximal";
		darwin = pkg: orNull stdenv.isDarwin pkg;
		linux = pkg: orNull stdenv.isLinux pkg;
		bash = "#!${pkgs.bash}/bin/bash";
		wrapper = script: writeScript "wrapper" script;
	in ([]) ++ lib.remove null ([
		# barrier
		daglink
		(darwin coreutils)
		(darwin cacert)
		(darwin fswatch)
		direnv
		dtach
		(self.gup-ocaml or gup)
		fish
		fzf
		git-wip
		(if (isEnabled "git-readonly" || stdenv.isDarwin) then null else git)
		(ifEnabled "git-readonly" (callPackage ./git-readonly.nix {}))
		(self.irank or null)
		irank-releases
		(ifEnabled "jdk" (callPackage ./jdks.nix {}))
		(ifEnabled "gnome-shell" my-gnome-shell-extensions)
		(anyEnabled [ "node" "maximal"] nodejs)
		my-nix-prefetch-scripts
		neovim
		neovim-remote
		pyperclip
		python3Packages.python
		ripgrep
		vim-watch
	]
	++ map (ifEnabled "vim-ide") [
		# ocaml-language-server
		# python3Packages.python-language-server
	] ++ map maximal (
		[
			# maximal:
			ctags
			glibcLocales
			python3Packages.ipython
			pythonPackages.youtube-dl
			syncthing
		] ++ map linux [
			# linux + maximal
			desktopFiles.my-desktop-session
			desktopFiles.tilda-launch
			desktopFiles.calibre

			jsonnet
			my-borg-task
			my-gnome-shell-extensions
			(ifEnabled "systemd" my-systemd-units)

			ocaml
			parcellite
			my-qt5
			xbindkeys
		]) # /maximal
	));

	siteInstalled = super.symlinkJoin {
		name = "local";
		paths = self.installedPackages;
		postBuild = ''
			for bin in $out/bin/*; do
				final_dest="$(readlink -f "$bin")"
				intermediate="$(readlink "$bin")"
				if [ "$final_dest" != "$intermediate" ]; then
					ln -sfn "$final_dest" "$bin"
				fi
			done
		'' + (
			# on darwin, git complains about OSX config, so delete it :(
			if stdenv.isDarwin then ''
			rm -f $out/bin/git
			'' else "");
	};

} // (let pkgs = self; in {

	# plain ol' packages:
	desktopFiles = callPackage ./apps.nix {};
	fish = if super.glibcLocales == null then super.fish else lib.overrideDerivation super.fish (o: {
		# workaround for https://github.com/NixOS/nixpkgs/issues/39328
		buildInputs = o.buildInputs ++ [ self.makeWrapper ];
		postInstall = ''
			wrapProgram $out/bin/fish --set LOCALE_ARCHIVE ${self.glibcLocales}/lib/locale/locale-archive
		'';
	});
	irank-releases = if self ? irank then (callPackage ({ lib, stdenv, makeWrapper, pythonPackages, irank }:
		let
			pythonDeps = [ irank ] ++ (with pythonPackages; [ musicbrainzngs pyyaml ]);
			pythonpath = lib.concatStringsSep ":" (map (dep: "${dep}/lib/${pythonPackages.python.libPrefix}/site-packages") pythonDeps);
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

	my-systemd-units = (pkgs.runCommand "systemd-units" {} ''
		mkdir -p $out/share/systemd
		cp -a "${self.system.config.system.build.standalone-user-units}" $out/share/systemd/user
	'');
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

	my-nix-prefetch-scripts = (
		# Override nix-prefetch-* scripts to include the system's .crt files,
		# so that https works as expected
		with callPackage ./caenv.nix {};
		let
			addVars = bin: ''
				bin="${bin}"
				base="$(basename "$bin")"
				dest="$out/bin/$base"
				echo "Wrapping $bin -> $dest"
				makeWrapper "$bin" "$dest" \
					${lib.concatMapStringsSep " " (var: "--set ${var} ${cacert}")}
			'';
		in
		stdenv.mkDerivation {
			priority=100;
			name = "my-nix-prefetch-scripts";
			buildInputs = with pkgs; [ makeWrapper ];
			unpackPhase = "true";
			buildPhase = "true";
			dontGzipMan = "true"; # They already are, ya fool!
			installPhase = ''
				mkdir -p $out/bin $out/share
				for f in ${pkgs.nix-prefetch-scripts}/bin/*; do
					${addVars "$f"}
				done
				for f in ${pkgs.nix}/bin/*; do
					${addVars "$f"}
				done
				cp -r ${pkgs.nix.man}/share/man $out/share/man
				${addVars "${pkgs.git}/bin/git"}
				${addVars "${pkgs.wget}/bin/wget"}
				${addVars "${pkgs.bundler}/bin/bundle"}
			'';
			meta.priority = 1;
		});

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
	pyperclip = callPackage ({ lib, fetchgit, pythonPackages, which, xsel }:
		pythonPackages.buildPythonPackage rec {
			name = "pyperclip-${version}";
			version = "dev";
			src = fetchgit {
				"url" = "https://github.com/timbertson/pyperclip-upstream.git";
				"rev" = "8fed9551596eef6dd8646c2a63d4239b9e5d2fdd";
				"sha256" = "1czxcdlx390ywkaccm69sk1nnlyax4y3ky5bps9yzyj6k8i1xh1w";
			};
			doCheck = false;
			propagatedBuildInputs = [ which xsel ];
		}) {};
	# pythonPackages = super.pythonPackages // {
	# 	# dnslib = tryCallLocal "${home}/dev/python/dns-alias" "nix/dnslib.nix" "HEAD" { inherit pythonPackages; };
	# };
	python3Packages = super.python3Packages // {
		python-language-server = super.python3Packages.python-language-server.override { providers = []; };
	};
	vimPlugins = (callPackage ./vim-plugins.nix {}) // super.vimPlugins;
})
