if exists(":CompilerSet") != 2
	command -nargs=* CompilerSet setlocal <args>
endif
CompilerSet makeprg=rubber\ --inplace\ \% &&\ gnome-open\ \%:r.dvi
