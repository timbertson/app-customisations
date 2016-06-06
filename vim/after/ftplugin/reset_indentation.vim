" echo "checking g:indent_preferred_expandtab"
if exists("g:indent_preferred_expandtab")
	" echo "using g:indent_preferred_expandtab"
	if g:indent_preferred_expandtab
		setlocal expandtab
	else
		setlocal noexpandtab
	endif
endif

" echo "checking g:indent_preferred_width"
if exists("g:indent_preferred_width")
	" echo "using g:indent_preferred_width"
	let &l:shiftwidth = g:indent_preferred_width
	let &l:softtabstop = g:indent_preferred_width
	let &l:tabstop = g:indent_preferred_width
endif


