if exists("loaded_sbt")
    finish
endif
let loaded_sbt=1

autocmd FileType scala compiler sbt
