if exists("did\_load\_filetypes")
		finish
endif
augroup filetypedetect
		au! BufRead,BufNewFile *.md      setfiletype mkd
		au! BufRead,BufNewFile *.coffee  setfiletype coffee
		au! BufRead,BufNewFile *.njs     setfiletype javascript
		au! BufRead,BufNewFile *.jss     setfiletype javascript
		au! BufRead,BufNewFile *.scala   setfiletype scala
		au! BufRead,BufNewFile *.as      setfiletype actionscript
		au! BufRead,BufNewFile *.ts      setfiletype javascript
augroup END
