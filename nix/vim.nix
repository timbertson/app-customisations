# TODO integrate with home-manager
{ pkgs, neovim-unwrapped ? pkgs.neovim-unwrapped }:
with pkgs;
let
	neovimUpstream = pkgs.wrapNeovim neovim-unwrapped { };
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
			pluginDictionaries = [
				# load always
				{
					names = [
						"async.vim"
						"asyncrun"
						"dhall-vim"
						"fish-syntax"
						"fugitive"
						"fzfWrapper"
						"fzf-vim"
						"indent-finder"
						"ir-black"
						"misc"
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
						"vim-grepper"
						"vim-indent-object"
						# "vim-lsp"
						"vim-nix"
						"vim-reason-plus"
						"vim-rust"
						"vim-stratifiedjs"
						"vim-swift"
						"vim-visual-star-search"
						"vim-watch"
					];
				}
				# full documentation at
				# github.com/MarcWeber/vim-addon-manager
			];
		};
	};
	vimrc = vimUtils.vimrcFile vimrcConfig;
	pathPrefixes = [silver-searcher python ctags] ++ (if stdenv.isLinux then [xclip] else []);
	wrapperArgs = with lib; concatStringsSep " \\\n"
		(map (base: "--prefix PATH : ${base}/bin") pathPrefixes);
in
stdenv.mkDerivation {
	# Note: not bothering to do a full `mkConfigurable`, just reusing the same vimrc
	name = "nvim-custom";
	buildInputs = [ makeWrapper ];
	unpackPhase = "true";
	passthru = { tim = "yeah!"; };
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
}
