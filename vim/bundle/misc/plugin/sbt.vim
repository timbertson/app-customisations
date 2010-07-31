let g:original_efm=&efm
function! Sbt()
	set efm=%E\ %#[error]\ %f:%l:\ %m,%C\ %#[error]\ %p^,%-C%.%#,%Z,
				\%W\ %#[warn]\ %f:%l:\ %m,%C\ %#[warn]\ %p^,%-C%.%#,%Z,
				\%-G%.%#
endfunction
command! -nargs=0 Sbt call Sbt()
