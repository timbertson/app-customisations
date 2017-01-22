{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
	home = builtins.getEnv "HOME";
	# exe = "${pkgs.my-borg}/bin/my-borg";
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
}
