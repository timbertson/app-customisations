version=date

0inst:
	mkdir -p 0inst

vim: 0inst phony
	(cd vim; tar phczf ../0inst/vim-custom.tgz *)
	cp 0inst/vim-custom.tgz 0inst/vim-custom-${version}.tgz
	mkzero-gfxmonk -v ${version} 0inst/vim-custom-${version}.tgz vim-custom.xml

xmonad: 0inst phony
	(cd xmonad; tar phczf ../0inst/xmonad-custom.tgz *)
	cp 0inst/xmonad-custom.tgz 0inst/xmonad-custom-${version}.tgz
	mkzero-gfxmonk -v ${version} 0inst/vim-custom-${version}.tgz xmonad-custom.xml

xmodmap: 0inst phony
	(cd xmodmap; tar phczf ../0inst/xmodmap-custom.tgz *)
	cp 0inst/xmodmap-custom.tgz 0inst/xmodmap-custom-${version}.tgz
	mkzero-gfxmonk -v ${version} 0inst/vim-custom-${version}.tgz xmodmap-custom.xml

.PHONY: phony
