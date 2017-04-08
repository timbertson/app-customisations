{ pkgs }:
with pkgs;
pkgs.stdenv.mkDerivation {
	name = "git-ro";
	buildCommand = ''
		mkdir -p $out/bin
		cat > $out/bin/git <<"EOF"
#!/${pkgs.bash}/bin/bash
set -e
function callgit {
	exec "${pkgs.git}/bin/git" "$@"
}
# This is not about security. This is just to
# prevent accidental writes
for f in "$@"; do
	case "$f" in
		--help) callgit "$@" ;;
		help) callgit "$@" ;;
		diff) callgit "$@" ;;
		status) callgit "$@" ;;
		grep) callgit "$@" ;;
		log) callgit "$@" ;;
		show-*) callgit "$@" ;;
		branch*) callgit branch -a ;; # hack!
		cat-file) callgit "$@" ;;
		ls-files) callgit "$@" ;;
		name-rev) callgit "$@" ;;
		rev-parse) callgit "$@" ;;
		archive) callgit "$@" ;;
		-*) continue ;;
		*)
			echo "command $f not allowed in RO mode" >&2
			exit 1
		;;
	esac
done
callgit
EOF
	chmod +x $out/bin/git
	'';
}
