if exists("did\_load\_filetypes")
    finish
endif
augroup markdown
    au! BufRead,BufNewFile *.md   setfiletype mkd
    au! BufRead,BufNewFile *.coffee   setfiletype coffee
    au! BufRead,BufNewFile *.njs   setfiletype javascript
    au! BufRead,BufNewFile *.jss   setfiletype javascript
		au! BufRead,BufNewFile *.scala setfiletype scala
augroup END
