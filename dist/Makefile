#version=20100617.2252
version=date

0inst:
	mkdir -p 0inst

vim: 0inst phony
	(cd vim; tar phczf ../0inst/vim-custom.tgz *)
	cp 0inst/vim-custom.tgz 0inst/vim-custom-${version}.tgz
	0publish-gfxmonk vim-custom ${version}

xmonad: 0inst phony
	(cd xmonad; tar phczf ../0inst/xmonad-custom.tgz *)
	cp 0inst/xmonad-custom.tgz 0inst/xmonad-custom-${version}.tgz
	0publish-gfxmonk xmonad-custom ${version}

xmodmap: 0inst phony
	(cd xmodmap; tar phczf ../0inst/xmodmap-custom.tgz *)
	cp 0inst/xmodmap-custom.tgz 0inst/xmodmap-custom-${version}.tgz
	0publish-gfxmonk xmodmap-custom ${version}

.PHONY: phony
