version=date

0inst:
	mkdir -p 0inst

vim: 0inst phony
	rm -f 0inst/vim-custom.tgz
	(cd vim; tar phczf ../0inst/vim-custom.tgz *)
	mkzero-gfxmonk -v ${version} -p 0inst/vim-custom.tgz vim-custom.xml

zsh-custom: 0inst phony
	rm -f 0inst/zsh-custom.tgz
	(cd zsh; tar phczf ../0inst/zsh-custom.tgz * .zshrc)
	mkzero-gfxmonk -v ${version} -p 0inst/zsh-custom.tgz zsh-custom.xml

tmux-custom: 0inst phony
	rm -f 0inst/tmux-custom.tgz
	(cd tmux; tar phczf ../0inst/tmux-custom.tgz *)
	mkzero-gfxmonk -v ${version} -p 0inst/tmux-custom.tgz tmux-custom.xml

misc-scripts: 0inst phony
	rm -f 0inst/misc-scripts.tgz
	(cd misc-scripts; tar phczf ../0inst/misc-scripts.tgz *)
	mkzero-gfxmonk -v ${version} -p 0inst/misc-scripts.tgz misc-scripts.xml

xmonad: 0inst phony
	rm -f 0inst/xmonad-custom.tgz
	(cd xmonad; tar phczf ../0inst/xmonad-custom.tgz *)
	mkzero-gfxmonk -v ${version} -p 0inst/vim-custom.tgz xmonad-custom.xml

xmodmap: 0inst phony
	rm -f 0inst/xmodmap-custom.tgz
	(cd xmodmap; tar phczf ../0inst/xmodmap-custom.tgz *)
	mkzero-gfxmonk -v ${version} -p 0inst/vim-custom.tgz xmodmap-custom.xml

.PHONY: phony
