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

		nodejs = lib.overrideDerivation nodejs (base: {
			preConfigure = ''
				if echo '1' | gcc -E -fstack-protector-strong - > /dev/null; then
					# we can't just test the version of gcc, since this feature is enabled by many distros prior to GCC 2.9
					export CFLAGS='-fstack-protector-strong'
				else
					export CFLAGS='-fstack-protector-all'
				fi
			'';
		});

	} // (if stdenv.isDarwin then {

		# XXX from https://github.com/NixOS/nixpkgs/issues/8728
		mercurial = lib.overrideDerivation pkgs.mercurial (base: with pythonPackages; {
			postInstall = ''
				for i in $(cd $out/bin && ls); do
					wrapProgram $out/bin/$i \
						--prefix PYTHONPATH : "$(toPythonPath "$out ${curses}")" \
						$WRAP_TK
				done
				mkdir -p $out/etc/mercurial
				cat >> $out/etc/mercurial/hgrc << EOF
				[web]
				cacerts = ${cacert}/etc/ssl/certs/ca-bundle.crt
				EOF
				# copy hgweb.cgi to allow use in apache
				mkdir -p $out/share/cgi-bin
				cp -v hgweb.cgi contrib/hgweb.wsgi $out/share/cgi-bin
				chmod u+x $out/share/cgi-bin/hgweb.cgi
				# install bash completion
				install -D -v contrib/bash_completion $out/share/bash-completion/completions/mercurial
			'';
		});
	} else {});
}

