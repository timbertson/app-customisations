# TODO integrate with home-manager
{ pkgs, neovim }:
with pkgs;
neovim.override {
	configure = {
		customRC = ''
			if !empty(glob("~/.vimrc"))
				source ~/.vimrc
			else
				source ${../vim/vimrc}
			endif
		'';
		# For a full list of builtin plugins: `nix-expr 'attrNames pkgs.vimPlugins'`
		packages.init = with pkgs.vimPlugins; {
			start = [
				# async-vim
				# asyncrun
				dhall-vim
				vim-fish
				fugitive
				fzfWrapper
				fzf-vim
				ir_black
				# misc
				vim-grepper
				repeat
				sensible
				Solarized
				(sleuth.overrideAttrs (o: {
					src = pkgs.vim-sleuth-src;
				}))
				NeoSolarized
				surround
				targets-vim
				tcomment_vim
				The_NERD_tree
				vim-indent-object
				# vim-lsp
				vim-nix
				rust-vim
				swift-vim
				# vim-watch
				];
			};
	};
}

