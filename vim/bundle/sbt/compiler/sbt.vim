if exists(":CompilerSet") != 2
	command -nargs=* CompilerSet setlocal <args>
endif
" CompilerSet makeprg=(sbt\ error\ compile\ $*\ \\\|\ sed\ -e\ \'s/[^[:print:]]//g\'\ \\\|\ sed\ -Ee\ \'s/\\[[0-9]+m//g\')
CompilerSet makeprg=(SBT_NO_COLOR=true\ sbt\ error\ compile\ $*)
CompilerSet errorformat=%E\ %#[error]\ %f:%l:\ %m,%C\ %#[error]\ %p^,%-C%.%#,%Z,\%W\ %#[warn]\ %f:%l:\ %m,%C\ %#[warn]\ %p^,%-C%.%#,%Z,\%-G%.%#

