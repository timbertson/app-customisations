# kept as its own file because it can be useful to `nix-shell caenv.nix` in an emergency
{ pkgs ? import <nixpkgs> {}}:
with pkgs; with lib;
let
	linux_cacert = "/etc/pki/tls/certs/ca-bundle.crt";
	nixpkgs_cacert = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
	cacert = if builtins.pathExists linux_cacert then linux_cacert else nixpkgs_cacert;
	envvars = [ "GIT_SSL_CAINFO" "CURL_CA_BUNDLE" "SSL_CERT_FILE " ];
	fishrc = writeTextFile {
		name = "nix-caenv.fish";
		text = (concatMapStringsSep "\n" (var:
			"set -x ${var} ${cacert}"
		) envvars);
	};
in
stdenv.mkDerivation ({
	name = "caenv";
	passthru = { inherit cacert envvars; };
	buildCommand = ''
		mkdir -p $out/share/fish
		cp ${fishrc} $out/share/fish/nix-caenv.fish
	'';
} // (listToAttrs (map (e: { name = e; value = cacert; }) envvars))
)
