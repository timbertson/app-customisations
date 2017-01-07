# Override nix-prefetch-* scripts to include the system's .crt files,
# so that https works as expected
# nix-prefetch-scripts = lib.overrideDerivation nix-prefetch-scripts (base: {
{ pkgs }:
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
}
