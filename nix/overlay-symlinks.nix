self: super:
with builtins;
with super.lib;
let
	home = (import ./session-vars.nix).home;
	link = name: localPath: symlinks:
	if pathExists localPath then listToAttrs [{
		inherit name;
		value = trace "Symlink: ${name} at ${localPath}" (super.stdenv.mkDerivation {
			name = "${name}-symlink";
			buildCommand = ''
				mkdir $out
				cd $out
				'' + (concatMapStringsSep "\n" (path: ''
					mkdir -p "$(dirname "${path.dest}")"
					ln -sfn ${localPath}/${path.src} ${path.dest}
				'') symlinks);
		});
	}]
	else {};
in
(link "git-wip" "${home}/dev/python/git-wip" [{ dest = "bin/git-wip"; src = "git-wip"; }])
