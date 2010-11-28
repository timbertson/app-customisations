if exists("loaded_sbt")
    finish
endif
let loaded_codefellow=1

autocmd FileType scala compiler sbt
