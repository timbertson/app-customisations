{pkgs ? import <nixpkgs> {}, pluginArgs ? {}}:
with pkgs;
let
	macvim = lib.overrideDerivation (pkgs.macvim) (o: {
		configureFlags = o.configureFlags ++ [ "--enable-perlinterp=no" ];
	});
	vim_configurable = if stdenv.isDarwin
		then vimUtils.makeCustomizable macvim
		else pkgs.vim_configurable;
	knownPlugins = vimPlugins // (pkgs.callPackage ./vim-plugins.nix pluginArgs);
	vim = vim_configurable.customize {
		name = "vim"; # actual binary name
		vimrcConfig.customRC = ''
			set nocompatible
			let g:vim_addon_manager.addon_completion_lhs=""
			if !empty(glob("~/.vimrc"))
				source ~/.vimrc
			else
				source ${../vim/vimrc}
			endif
		'';
		vimrcConfig.vam = {
			inherit knownPlugins;
			pluginDictionaries = [
				# load always
				{
					names = [
						"ack.vim"
						"ctrlp"
						"command-t"
						"fish-syntax"
						"fugitive"
						"indent-finder"
						"ir-black"
						"misc"
						"multiple-cursors"
						"repeat"
						"Solarized"
						"surround"
						"Tagbar"
						"tcomment"
						"The_NERD_tree"
						"vim-indent-object"
						"vim-nix"
						"vim-rust"
						"vim-stratifiedjs"
						"vim-visual-star-search"
						"vim-watch"
					]
					++ (if knownPlugins.gsel == null then [] else ["gsel"]);
				}
				# full documentation at
				# github.com/MarcWeber/vim-addon-manager
			];
		};
	};
in
stdenv.mkDerivation {
	name = "vim-custom";
	buildInputs = [ makeWrapper ];
	unpackPhase = "true";
	installPhase = ''
		mkdir -p $out/bin
		makeWrapper ${vim}/bin/vim $out/bin/vim \
			--prefix PATH : ${silver-searcher}/bin \
			--prefix PATH : ${ctags}/bin \
		;
		echo -e "#!${bash}/bin/bash\nexec \"$out/bin/vim\" -g \"\$@\"" > $out/bin/gvim
		chmod +x $out/bin/*
	'';
}
