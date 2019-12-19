{ pkgs ? import <nixpkgs> {}}:
with pkgs.lib;
let
	linux_cacert = "/etc/pki/tls/cacerts/ca-bundle.crt";
	nixpkgs_cacert = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
	cacert = if builtins.pathExists linux_cacert then linux_cacert else nixpkgs_cacert;
	envvars = [ "GIT_SSL_CAINFO" "CURL_CA_BUNDLE" "SSL_CERT_FILE " ];
in
pkgs.mkShell ({
	passthru = { inherit cacert envvars; };
} // (listToAttrs (map (e: { name = e; value = cacert; }) envvars))
)
