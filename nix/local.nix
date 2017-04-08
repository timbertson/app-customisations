{pkgs ? import <nixpkgs> {}}:
let packagesExt = pkgs // (import ./packages.nix { inherit pkgs; }); in
with packagesExt;
let
	defaultOpts = {
		syncthing = false;
		maximal = false;
	};
	home = builtins.getEnv "HOME";
	optsPath = "${home}/.nixpkgs/opts.nix";
	opts = defaultOpts // (if builtins.pathExists optsPath then import optsPath else {});
	isDarwin = stdenv.isDarwin;
	isLinux = stdenv.isLinux;
	optional = flag: pkg: if flag then pkg else null;
	maximal = pkg: optional opts.maximal pkg;
	bash = "#!${pkgs.bash}/bin/bash";
	wrapper = script: writeScript "wrapper" script;
	wrappers = {
		# ALL

	} // (if isLinux && opts.maximal then {
		# LINUX only...
		"mount.ssh" = wrapper ''${bash}
			set -eu
			if [ "$#" -lt 2 ]; then
				echo "usage: mount.ssh [opts] remote local-dir"
				exit 2
			fi
			if [ ! -e "$2" ]; then
				echo "Making directory: $2"
				mkdir -p "$2"
			fi

			${sshfsFuse}/bin/sshfs "$@"
		'';

	} else {});
	installed = with lib; remove null ([
		git
		my-nix-prefetch-scripts
		daglink
		(maximal gsel)
		(maximal ctags)
		fish
		(maximal nodejs)
		direnv
		ripgrep
		(maximal music-import)
		gup
		(maximal passe-client)
		vim-watch
		vim
		vim.vimrc
		(maximal python2Packages.ipython)
		(maximal python3Packages.ipython)
		pyperclip
		(optional opts.syncthing syncthing)

		(buildFromSource ./sources/piep.json)
		(buildFromSource ./sources/version.json)
	] ++ (if !opts.maximal then [] else if isLinux then with ocamlPackages_4_03; [
		#tilda
		pythonPackages.gsutil
		spotify
		xbindkeys
		jsonnet
		pythonPackages.youtube-dl
		irank
		irank-releases
		eog-rate
		my-borg-task
		ocamlscript
		ocaml
		vlc
		parcellite
		dumbattr
		shellshape
		snip
		trash
		(runCommand "systemd-units" {} ''
			mkdir -p $out/share/systemd
			cp -a "${system.config.system.build.standalone-user-units}" $out/share/systemd/user
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
		# darwin
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
	'';
}
