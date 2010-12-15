if exists("loaded_rubber")
    finish
endif
let loaded_rubber=1

autocmd! FileType tex compiler rubber
