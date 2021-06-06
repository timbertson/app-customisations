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
		# For a full list of builtin plugins: `nix-expr attrNames pkgs.vimPlugins`
		plug.plugins = with pkgs.vimPlugins; [
			# async-vim
			# asyncrun
			dhall-vim
			vim-fish
			fugitive
			fzfWrapper
			fzf-vim
			ir_black
			# misc
			repeat
			sensible
			Solarized
			# indent-finder # trying sleuth instead..
			sleuth
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
}

