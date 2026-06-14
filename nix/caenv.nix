# kept as its own file because it can be useful to `nix-shell caenv.nix` in an emergency
{ pkgs ? import <nixpkgs> {}}:
with pkgs; with lib;
let
	linux_cacert_file = "/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem";
	linux_cacert_dir = "/etc/pki/ca-trust/extracted/pem";
	nixpkgs_cacert_file = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
	nixpkgs_cacert_dir = "${pkgs.cacert}/etc/ssl/certs";
	cacert_file = if builtins.pathExists linux_cacert_file then linux_cacert_file else nixpkgs_cacert_file;
	cacert_dir = if builtins.pathExists linux_cacert_dir then linux_cacert_dir else nixpkgs_cacert_dir;

	dir_envvars = [ "GIT_SSL_CAPATH" "SSL_CERT_DIR " ];

	# file-based is legacy since it's slower than dir-based
	file_envvars = [ "GIT_SSL_CAINFO" "CURL_CA_BUNDLE" "SSL_CERT_FILE " ];

	fishrc = writeTextFile {
		name = "nix-caenv.fish";
		text = (concatMapStringsSep "\n" (var:
			"set -x ${var} ${cacert_file}"
			) file_envvars)
			+ "\n" +
			(concatMapStringsSep "\n" (var:
			"set -x ${var} ${cacert_dir}"
			) dir_envvars)
			;
	};
in
stdenv.mkDerivation ({
	name = "caenv";
	passthru = { inherit cacert_dir cacert_file; };
	buildCommand = ''
		mkdir -p $out/share/fish
		cp ${fishrc} $out/share/fish/nix-caenv.fish
	'';
})
