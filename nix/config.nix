{
	allowUnfree = true;
	packageOverrides = pkgs: with pkgs; let
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
			;
		'';
	in {
		
		# Override nix-prefetch-* scripts to include the system's .crt files,
		# so that https works as expected
		# nix-prefetch-scripts = lib.overrideDerivation nix-prefetch-scripts (base: {
		my-nix-prefetch-scripts = stdenv.mkDerivation {
			name = "my-nix-prefetch-scripts";
			buildInputs = with pkgs; [ makeWrapper ];
			unpackPhase = "true";
			buildPhase = "true";
			installPhase = ''
				mkdir -p $out/bin
				for f in ${pkgs.nix-prefetch-scripts}/bin/*; do
					${addVars "$f"}
				done
				${addVars "${pkgs.nix}/bin/nix-prefetch-url"}
				${addVars "${pkgs.git}/bin/git"}
			'';
			meta.priority = 1;
		};

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

