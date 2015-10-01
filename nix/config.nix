let
	addVars = bin: ''
		echo "Wrapping ${bin}"
		bin="${bin}"
		# EWW EWW EWW!
		base="$(basename "$bin")"
		dir="$(dirname "$bin")"
		dest="$dir/.$base-wrapped"
		if [ -e "$dest" ]; then
			bin="$dest"
		fi
		wrapProgram "$bin" \
			--set GIT_SSL_CAINFO  /etc/pki/tls/certs/ca-bundle.crt \
			--set CURL_CA_BUNDLE /etc/pki/tls/certs/ca-bundle.crt \
		;
	'';
in
{
	allowUnfree = true;
	packageOverrides = pkgs: with pkgs; {
		
		# Override nix-prefetch-* scripts to include fedora's .crt files,
		# so that https works as expected
		# nix-prefetch-scripts = lib.overrideDerivation nix-prefetch-scripts (base: {
		my-nix-prefetch-scripts = lib.overrideDerivation pkgs.nix-prefetch-scripts (base: {
			preFixup = (base.preFixup or "") + ''
				for f in $out/bin/*; do
					${addVars "$f"}
				done
			'';
		});

		my-nix = lib.overrideDerivation nix (base: {
			buildInputs = (base.buildInputs or []) ++ [pkgs.makeWrapper];
			preFixup = (base.preFixup or "") + (addVars "$out/bin/nix-prefetch-url");
			meta.priority = 1;
		});

		# nodejs = lib.overrideDerivation nodejs (base: {
		# 	preConfigure = ''
		# 		if echo '1' | gcc -E -fstack-protector-strong - > /dev/null; then
		# 			# we can't just test the version of gcc, since this feature is enabled by many distros prior to GCC 2.9
		# 			export CFLAGS='-fstack-protector-strong'
		# 		else
		# 			export CFLAGS='-fstack-protector-all'
		# 		fi
		# 	'';
		# });

		binutils-efi = lib.overrideDerivation binutils (o: {
			# configureFlags = o.configureFlags ++ [ "--enable-targets=all"];
			configureFlags = o.configureFlags ++ [ "--enable-targets=x86_64-pep"];
			# configureFlags = o.configureFlags ++ [ "--enable-targets=i386-efi-pe"];
		});

		sitePackages = if builtins.pathExists "${builtins.getEnv "HOME"}/dev/app-customisations/nix"
			then {
				recurseForDerivations = false;
				inherit (import ~/dev/app-customisations/nix/packages.nix { inherit pkgs; }) gup passe-client;
			}
			else null;

	}
	# // (import ./packages {inherit pkgs; })
	// (if stdenv.isDarwin then {
	} else {});
}

