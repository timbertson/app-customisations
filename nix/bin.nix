{pkgs ? import <nixpkgs> {}}:
with pkgs;
let
	bash = "#!${pkgs.bash}/bin/bash";
	wrapper = script: writeScript "wrapper" script;
	wrappers = {
		# ALL

	} // (if stdenv.isDarwin then {} else {
		# LINUX only...
		"mount.ssh" = wrapper ''${bash}
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
	});
	tools = [
		git
		ctags
		fish
		direnv
		(callPackage ./packages/vim-watch.nix {})
		(callPackage ./vim {})
	];
	dirs = "bin etc share/man";
in
stdenv.mkDerivation {
	name = "my-nix-scripts";
	unpackPhase = "true";
	buildPhase = "true";
	installPhase = with lib; ''
		mkdir "$out"
		cd "$out"
		mkdir -p ${dirs}
		${
			# TODO: link all man files, too
			concatStringsSep "\n" (map (base:
				''
				for d in ${dirs}; do
					if [ -d "${base}/$d" ]; then
						echo "linking ${base}/$d ..."
						${pkgs.xlibs.lndir}/bin/lndir "${base}/$d" "$d"
					fi
				done
				''
			) tools)
		}

		${
			concatStringsSep "\n" (mapAttrsToList (name: script:
				"ln -sfn ${script} bin/${name}"
			) wrappers)
		}
	'';
}
