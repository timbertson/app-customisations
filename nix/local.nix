{pkgs ? import <nixpkgs> {}}:
let
	stdenv = pkgs.stdenv;
	home = builtins.getEnv "HOME";
	optsPath = "${home}/.nixpkgs/opts.nix";
	opts = defaultOpts // (if builtins.pathExists optsPath then import optsPath else {});
	packagesExt = pkgs // (import ./packages.nix {
		inherit pkgs;
		enableNeovim = true;
	});
	isDarwin = stdenv.isDarwin;
	isLinux = stdenv.isLinux;
in
with packagesExt; let
	installed = with lib; remove null ([
		(if opts.git-readonly then callPackages ./git-readonly.nix {} else (notDarwin git))
		my-nix-prefetch-scripts
		(darwin coreutils)
		(darwin cacert)
		(maximal abduco)
		daglink
		dtach
		(maximal ctags)
		fzf
		fish
		(darwin fswatch)
		(maximal glibcLocales)
		(maximal nodejs)
		direnv
		ripgrep
		nix-pin
		(maximal music-import)
		git-wip
		gup
		(maximal passe)
		vim-watch
		vim.vimrc
		neovim
		neovim-remote
		(maximal python2Packages.ipython)
		(maximal python3Packages.ipython)
		python3Packages.python
		pyperclip
		(optional opts.syncthing syncthing)
		(buildFromSource ./sources/piep.json {})
		(buildFromSource ./sources/version.json {})
	] ++ (if !opts.maximal then [] else if isLinux then with ocamlPackages_4_03; [
		#tilda
		google-cloud-sdk
		xbindkeys
		jsonnet
		parallel
		pythonPackages.youtube-dl
		irank
		irank-releases
		eog-rate
		my-borg-task
		ocamlscript
		ocaml
		parcellite
		dumbattr
		shellshape
		snip
		stereoscoper
		template
		trash
		(runCommand "systemd-units" {} ''
			mkdir -p $out/share/systemd
			cp -a "${system.config.system.build.standalone-user-units}" $out/share/systemd/user
		'')
		(runCommand "ocaml-language-server" {} ''
			mkdir -p $out/bin
			ln -s "${nodePackages.ocaml-language-server}/bin/ocaml-language-server" "$out/bin"
		'')
		(import ./applications.nix {inherit pkgs; })
		(runCommand "gnome-shell-extensions" {} ''
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
				'') gnome-shell-extensions))
			}
		'')
	] else [
		# darwin maximal
	]) ++ (
		mapAttrsToList (name: script:
			runCommand "${name}-wrapper" {} ''
				mkdir -p $out/bin
				ln -s ${script} $out/bin/${name}
			''
		) wrappers
	));
	dirs = [ "bin" "etc" "share"];
	system = import ./system.nix { pkgs = packagesExt; };
	gnome-shell-extensions = import ./gnome-shell.nix { pkgs = packagesExt; };
in
symlinkJoin { name = "local"; paths = installed;
	postBuild = ''
		for bin in $out/bin/*; do
			final_dest="$(readlink -f "$bin")"
			intermediate="$(readlink "$bin")"
			if [ "$final_dest" != "$intermediate" ]; then
				ln -sfn "$final_dest" "$bin"
			fi
		done
	'' + (
		# on darwin, git complains about OSX config, so detele it :(
		if isDarwin then ''
		rm -f $out/bin/git
		'' else "");
}
