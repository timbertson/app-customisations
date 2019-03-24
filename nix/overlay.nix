self: super:
with builtins;
with super.lib;
let
	defaultFeatures = {
		maximal = false;
		git-readonly = false;
		gnome-shell = false;
		syncthing = false;
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

	ifEnabled = feature: x: if isEnabled feature then x else null;

	orNull = cond: x: if cond then x else null;

	home = builtins.getEnv "HOME";

	tryCallPackageFrom = src: path: args: withExtantPath path (path:
		src.callPackage path args
	);

	tryCallPackage = tryCallPackageFrom self;

	tryBuildHaskell = tryInvoke (path:
		pkgs.haskell.packages.ghc862.callPackage path { }
	);

	buildFromSource = jsonFile: attrs:
		let
			fetched = super.nix-update-source.fetch jsonFile;
			pkg = (callPackage "${fetched.src}/nix/default.nix" attrs);
		in
		pkg.overrideAttrs (base: {
			name = "${fetched.repo}-${fetched.version or fetched.fetch.version}";
			inherit (fetched) src;
		});
in
{
	features = defaultFeatures;
	siteLib = {
		inherit
			isEnabled
		;
	};

	installedPackages = with self; (let
		maximal = ifEnabled "maximal";
		darwin = pkg: orNull stdenv.isDarwin pkg;
		linux = pkg: orNull stdenv.isLinux pkg;
		bash = "#!${pkgs.bash}/bin/bash";
		wrapper = script: writeScript "wrapper" script;
	in lib.remove null ([
		(buildFromSource ./sources/piep.json {})
		(buildFromSource ./sources/version.json {})
		daglink
		(darwin coreutils)
		(darwin cacert)
		(darwin fswatch)
		direnv
		dtach
		(firstNonNull [gup-ocaml gup])
		fish
		fzf
		git-wip
		(if (isEnabled "git-readonly" || stdenv.isDarwin) then null else git)
		(ifEnabled "git-readonly" (callPackage ./git-readonly.nix {}))
		(ifEnabled "gnome-shell" my-gnome-shell-extensions)
		(ifEnabled "syncthing" syncthing)
		(maximal abduco)
		(maximal ctags)
		(maximal glibcLocales)
		(maximal nodejs)
		(maximal music-import)
		(maximal python3Packages.ipython)
		(maximal passe)
		my-nix-prefetch-scripts
		neovim
		neovim-remote
		nix-pin
		pyperclip
		python3Packages.python
		ripgrep
		vim-watch
	]
	++ map (ifEnabled "vim-ide") [
		ocaml-language-server
		python3Packages.python-language-server
	] ++ map maximal (
		[
			# maximal:
			snip
			stereoscoper
			pythonPackages.youtube-dl
			trash
		] ++ map linux [
			# linux + maximal
			desktopFiles.my-desktop-session
			desktopFiles.tilda-launch
			desktopFiles.calibre
			dumbattr
			eog-rate
			irank
			irank-releases
			jsonnet
			my-borg-task
			my-gnome-shell-extensions
			(ifEnabled "systemd" my-systemd-units)
			ocaml
			parcellite
			xbindkeys
		]) # /maximal
	));

	siteInstalled = self.symlinkJoin {
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
	daglink = buildFromSource ./sources/daglink.json {};
	dconf-user-overrides = tryCallPackage "${home}/dev/python/dconf-user-overrides/nix/local.nix" {};
	desktopFiles = callPackage ./apps.nix {};
	dns-alias = tryCallPackage "${home}/dev/python/dns-alias/nix/default.nix" {};
	dumbattr = tryCallPackage "${home}/dev/python/dumbattr/nix/local.nix" {};
	eog-rate = tryCallPackage "${home}/dev/python/eog-rate/nix/local.nix" {};
	fish = if super.glibcLocales == null then super.fish else lib.overrideDerivation super.fish (o: {
		# workaround for https://github.com/NixOS/nixpkgs/issues/39328
		buildInputs = o.buildInputs ++ [ self.makeWrapper ];
		postInstall = ''
			wrapProgram $out/bin/fish --set LOCALE_ARCHIVE ${self.glibcLocales}/lib/locale/locale-archive
		'';
	});
	git-wip = buildFromSource ./sources/git-wip.json {};
	gup-ocaml = (tryCallPackageFrom super "${home}/dev/ocaml/gup/nix/gup-ocaml.nix" {});
	irank = tryCallPackage "${home}/dev/python/irank/default.nix" {};
	irank-releases = callPackage ({ lib, stdenv, makeWrapper, pythonPackages, irank }:
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
		});

	jsonnet = callPackage ({ stdenv, fetchurl }:
		let
			version = "0.8.5";
		in
		stdenv.mkDerivation {
			name = "jsonnet-${version}";
			src = fetchurl {
				url = "https://github.com/google/jsonnet/archive/v${version}.tar.gz";
				sha256 = "1b6whj7ad0zlq3smrnf6c6friipkgny6kqdcbjnbll21jmpzhkai";
			};
			makeFlags = "libjsonnet.so jsonnet";
			installPhase = ''
				mkdir $out
				mkdir $out/bin
				mkdir $out/lib
				cp jsonnet $out/bin/
				cp libjsonnet.so $out/lib/
			'';
		});

	music-import = tryCallPackage "${home}/dev/python/music-import/nix/local.nix" {};
	my-systemd-units = (runCommand "systemd-units" {} ''
		mkdir -p $out/share/systemd
		cp -a "${system.config.system.build.standalone-user-units}" $out/share/systemd/user
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
		});

	my-gnome-shell-extensions =
		let exts = {
			"scroll-workspaces@gfxmonk.net" = "${home}/dev/gnome-shell/scroll-workspaces";
			"impatience@gfxmonk.net" = "${home}/dev/gnome-shell/impatience@gfxmonk.net";
		}; in (runCommand "gnome-shell-extensions" {} ''
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
		with pkgs;
		let
			linux_cacert = "/etc/pki/tls/cacerts/ca-bundle.crt";
			nixpkgs_cacert = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
			cacert = if builtins.pathExists linux_cacert then linux_cacert else nixpkgs_cacert;
			addVars = bin: ''
				bin="${bin}"
				base="$(basename "$bin")"
				dest="$out/bin/$base"
				echo "Wrapping $bin -> $dest"
				makeWrapper "$bin" "$dest" \
					--set GIT_SSL_CAINFO ${cacert} \
					--set CURL_CA_BUNDLE ${cacert} \
					--set SSL_CERT_FILE ${cacert} \
				;
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

	neovim = callPackage ./vim.nix {};
	ocaml-language-server = (runCommand "ocaml-language-server" {} ''
		mkdir -p $out/bin
		ln -s "${nodePackages.ocaml-language-server}/bin/ocaml-language-server" "$out/bin"
	'');
	opam2nix = tryCallPackageFrom super ./opam2nix-packages {};
	passe = tryCallPackage "${home}/dev/ocaml/passe/nix/default.nix" { target="client"; };
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
	pythonPackages = super.pythonPackages // {
		dnslib = tryCallPackage "${home}/dev/python/dns-alias/nix/dnslib.nix" { inherit pythonPackages; };
	};
	python3Packages = super.python3Packages // {
		python-language-server = super.python3Packages.python-language-server.override { providers = []; };
	};
	shellshape = tryCallPackage "${home}/dev/gnome-shell/shellshape@gfxmonk.net/default.nix" {};
	snip = tryBuildHaskell "${home}/dev/haskell/snip/nix/default.nix" ;
	stereoscoper = tryCallPackage "${home}/dev/python/stereoscoper/default.nix" {};
	trash = tryCallPackage "${home}/dev/python/trash/default.nix" {};
	vimPlugins = (callPackage ./vim-plugins.nix {}) // super.vimPlugins;
	vim-watch = firstNonNull [
		(tryCallPackage "${home}/dev/vim/vim-watch/nix/local.nix" { enableNeovim = true; })
		(buildFromSource ./sources/vim-watch.json { enableNeovim = true; })
	];
})
