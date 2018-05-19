{pkgs ? import <nixpkgs> {}, pluginArgs ? {}}:
with pkgs;
let
	knownPlugins = (pkgs.callPackage ./vim-plugins.nix pluginArgs) // vimPlugins;

	neovimUpstream = pkgs.wrapNeovim (lib.overrideDerivation pkgs.neovim-unwrapped (o: {
		patches = (o.patches or []) ++ [ ./nvim-mouse.diff ];
	}) ) { };

	vimrcConfig = {
		customRC = ''
			set nocompatible
			let g:vim_addon_manager.addon_completion_lhs=""
			if !empty(glob("~/.vimrc"))
				source ~/.vimrc
			else
				source ${../vim/vimrc}
			endif
		'';
		vam = {
			inherit knownPlugins;
			pluginDictionaries = [
				# load always
				{
					names = [
						"asyncrun"
						# "ack.vim"
						"ctrlp" # used for gvim without terminal
						"fish-syntax"
						"fugitive"
						"fzfWrapper"
						"fzf-vim"
						"indent-finder"
						"ir-black"
						"misc"
						# "multiple-cursors"
						# "neomake"
						"repeat"
						"sensible"
						"Solarized"
						"NeoSolarized"
						"neoterm"
						"surround"
						"Tagbar"
						"targets"
						"tcomment"
						"The_NERD_tree"
						"vala.vim"
						"vim-indent-object"
						"vim-grepper"
						"vim-nix"
						"vim-rust"
						"vim-stratifiedjs"
						"vim-swift"
						"vim-visual-star-search"
						"vim-watch"
					]
					# ++ (if knownPlugins.gsel == null then [] else ["gsel"])
					# ++ (if stdenv.isDarwin then [] else ["command-t"])
					;
				}
				# full documentation at
				# github.com/MarcWeber/vim-addon-manager
			];
		};
	};
	vim = vim_configurable.customize {
		name = "vim"; # actual binary name
		inherit vimrcConfig;
	};
	vimrc = vimUtils.vimrcFile vimrcConfig;
	pathPrefixes = [silver-searcher python ctags] ++ (if stdenv.isLinux then [xclip] else []);
	wrapperArgs = with lib; concatStringsSep " \\\n"
		(map (base: "--prefix PATH : ${base}/bin") pathPrefixes);
in
stdenv.mkDerivation {
	name = "vim-custom";
	buildInputs = [ makeWrapper ];
	unpackPhase = "true";
	passthru = {
		vimrc = runCommand "vimrc" {} ''
			mkdir -p $out/share/vim/
			ln -s ${vimrc} $out/share/vim/vimrc
		'';

		neovim = stdenv.mkDerivation {
			# XXX not bothering to do a full `mkConfigurable`, just reusing the same vimrc
			name = "nvim-custom";
			buildInputs = [ makeWrapper ];
			unpackPhase = "true";
			# note: nvim-remote relies on the binary being named "nvim", so we have to do an awkward copy-dance...
			installPhase = ''
				mkdir -p $out/bin
				mkdir -p $out/libexec/nvim
				ORIG_BINARY=${neovimUpstream}/bin/nvim
				NEW_BINARY=$out/libexec/nvim/nvim

				cp -a $ORIG_BINARY $NEW_BINARY

				makeWrapper $NEW_BINARY $out/bin/nvim \
					${wrapperArgs} \
					--add-flags -u \
					--add-flags ${vimrc} \
				;
				chmod +x $out/bin/nvim
			'';
		};
	};
	installPhase = ''
		mkdir -p $out/bin
		makeWrapper ${vim}/bin/vim $out/bin/vim \
			${wrapperArgs} \
		;
		echo -e "#!${bash}/bin/bash\nexec \"$out/bin/vim\" -g \"\$@\"" > $out/bin/gvim
		chmod +x $out/bin/*
	'';
}
