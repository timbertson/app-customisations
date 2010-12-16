if exists(":CompilerSet") != 2
	command! -nargs=* CompilerSet setlocal <args>
endif
CompilerSet makeprg=rubber\ --inplace\ \%\ &&\ dvipdf\ \%:r.dvi\ &&\ gnome-open\ \%:r.pdf
