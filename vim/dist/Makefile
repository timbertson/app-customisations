version=20100617.2252
#version=date
dist:
	mkdir -p 0inst
	(cd build; tar phczf ../0inst/vim-custom.tgz *)
	cp 0inst/vim-custom.tgz 0inst/vim-custom-${version}.tgz
	0publish-gfxmonk vim-custom ${version}

.PHONY: dist
