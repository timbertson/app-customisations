" Name:          autotab (global plugin)
" Version:       0.1
" Authors:       Tim Cuthbertson (tab conversion)
"                Ciaran McCreesh (detectindent author)
"
" Updates:       http://github.com/gfxmonk/vim-autotab
"
" Purpose:       Detect indent settings and convert space-based indents
"                to tabs. On file write, convert everything back to
"                the original format.
"
" License:       You may redistribute this plugin under the same terms as Vim
"                itself.
"
" Usage:         Enable with :Autotab
"                There is currently no way to disable.

if exists("loaded_autotab")
	finish
endif
let loaded_autotab = 1

fun! <SID>IsCommentStart(line)
	" &comments isn't reliable
	if &ft == "c" || &ft == "cpp"
		return -1 != match(a:line, '/\*')
	else
		return 0
	endif
endfun

fun! <SID>IsCommentEnd(line)
	if &ft == "c" || &ft == "cpp"
		return -1 != match(a:line, '\*/')
	else
		return 0
	endif
endfun

fun! <SID>newFile()
	"call <SID>detectTabs()
	"call <SID>tabify()
	" it's safer this way..
	call UnAutotab()
endfun

fun! <SID>detectTabs()
	let b:detected_tab_width = <SID>DetectIndent()
	call <SID>debug(b:detected_tab_width)
endfun

fun! <SID>tabify()
	if ! exists("s:detected_tab_width")
		call <SID>detectTabs()
	endif
	if ! b:detected_tab_width
		return
	endif
	let l:sub_cmd = "substitute(" .
		\"v:val, " .
		\"'" . '^\t*' .
			\'\zs' .
			\'\( \{' . b:detected_tab_width . '}\)\+' . "', " .
		\"'" . '\=repeat("\t", ' .
			\'strlen(submatch(0)) / '. b:detected_tab_width .')' . "'" . ', "")'

	call <SID>debug(l:sub_cmd)
	call setline(1, map(getline(1,"$"), l:sub_cmd))
	" we've just saved or read the file, we haven't *actually* changed it..
	set nomodified
endfun

" let g:autotab_debug = 1
" ^ to turn on debugging
fun! <SID>debug(s)
	if exists("g:autotab_debug") && g:autotab_debug
		echo(a:s)
	endif
endfun

fun! <SID>untabify()
	if ! b:detected_tab_width
		return
	endif
	let l:sub_cmd = "substitute(" .
		\"v:val, " .
		\"'" . '^ *' .
			\'\zs' .
			\'\t\+' . "', " .
		\"'" . '\=repeat(" ", ' .
			\'strlen(submatch(0)) * '. b:detected_tab_width .')' . "'" . ', "")'

	call <SID>debug(l:sub_cmd)
	call setline(1, map(getline(1,"$"), l:sub_cmd))
endfun

fun! <SID>DetectIndent()
	let l:has_leading_tabs = 0
	let l:has_leading_spaces = 0
	let l:shortest_leading_spaces_run = 0
	let l:longest_leading_spaces_run = 0
	let l:max_lines = 1024
	if exists("g:detectindent_max_lines_to_analyse")
		let l:max_lines = g:detectindent_max_lines_to_analyse
	endif

	let l:idx_end = line("$")
	let l:idx = 1
	while l:idx <= l:idx_end
		let l:line = getline(l:idx)

		" try to skip over comment blocks, they can give really screwy indent
		" settings in c/c++ files especially
		if <SID>IsCommentStart(l:line)
			while l:idx <= l:idx_end && ! <SID>IsCommentEnd(l:line)
				let l:idx = l:idx + 1
				let l:line = getline(l:idx)
			endwhile
			let l:idx = l:idx + 1
			continue
		endif

		" Skip lines that are solely whitespace, since they're less likely to
		" be properly constructed.
		if l:line !~ '\S'
			let l:idx = l:idx + 1
			continue
		endif

		let l:leading_char = strpart(l:line, 0, 1)

		if l:leading_char == "\t"
			let l:has_leading_tabs = 1

		elseif l:leading_char == " "
			" only interested if we don't have a run of spaces followed by a
			" tab.
			if -1 == match(l:line, '^ \+\t')
				let l:has_leading_spaces = 1
				let l:spaces = strlen(matchstr(l:line, '^ \+'))
				if l:shortest_leading_spaces_run == 0 || ( l:spaces < l:shortest_leading_spaces_run && l:spaces > 1 )
					let l:shortest_leading_spaces_run = l:spaces
				endif
				if l:spaces > l:longest_leading_spaces_run
					let l:longest_leading_spaces_run = l:spaces
				endif
			endif
		endif
		let l:idx = l:idx + 1
		let l:max_lines = l:max_lines - 1
		if l:max_lines == 0
			let l:idx = l:idx_end + 1
		endif

	endwhile

	if l:has_leading_spaces
		return l:shortest_leading_spaces_run
	else
		return 0
	endif
endfun

fun! <SID>AutoTab()
	autocmd BufReadPost <buffer> call <SID>newFile()
	autocmd BufWritePost,FileWritePost,FileAppendPost <buffer> call <SID>tabify()
	autocmd BufWritePre,FileWritePre,FileAppendPre <buffer> call <SID>untabify()
	call <SID>tabify()
endfun

fun! <SID>UnAutotab()
	<SID>untabify()
	" remove all buffer-local autocommands
	autocmd! * <buffer>
endfun

command! -nargs=0 Autotab call <SID>AutoTab()
command! -nargs=0 UnAutotab call <SID>UnAutotab()

