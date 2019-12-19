{ pkgs ? import <nixpkgs> {}}:
with pkgs; with lib;
let
	linux_cacert = "/etc/pki/tls/cacerts/ca-bundle.crt";
	nixpkgs_cacert = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
	cacert = if builtins.pathExists linux_cacert then linux_cacert else nixpkgs_cacert;
	envvars = [ "GIT_SSL_CAINFO" "CURL_CA_BUNDLE" "SSL_CERT_FILE " ];
	fishrc = writeTextFile "nix-caenv.fish" (concatMapStringsSep "\n" (var:
		"set -x ${var} ${cacert}"
	)) envvars;
in
stdenv.mkDerivation ({
	passthru = { inherit cacert envvars; };
	buildCommand = ''
		mkdir -p $out/share/fish
		cp ${fishrc} $out/share/fish/nix-caenv.fish
	'';
} // (listToAttrs (map (e: { name = e; value = cacert; }) envvars))
)
