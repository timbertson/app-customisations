version=date

0inst:
	mkdir -p 0inst

vim: 0inst phony
	mkzero-gfxmonk -p vim -x vim -v ${version} --resolve-links vim-custom.xml

vim-custom-local.xml: vim-custom.xml
	0local -p ./vim vim-custom.xml

zsh-custom: 0inst phony
	mkzero-gfxmonk -p zsh -x zsh -v ${version} --resolve-links zsh-custom.xml

tmux-custom: 0inst phony
	mkzero-gfxmonk -p tmux -x tmux -v ${version} --resolve-links tmux-custom.xml

misc-scripts: 0inst phony
	mkzero-gfxmonk -p misc-scripts -x misc-scripts -v ${version} --resolve-links misc-scripts.xml

misc-scripts-local.xml: misc-scripts.xml
	0local -p ./misc-scripts misc-scripts.xml

xmonad: 0inst phony
	mkzero-gfxmonk -p xmonad -x xmonad -v ${version} --resolve-links xmonad-custom.xml

xmodmap: 0inst phony
	mkzero-gfxmonk -p xmodmap -x xmodmap -v ${version} --resolve-links xmodmap-custom.xml

.PHONY: phony
