fun! <SID>BackgroundMake(args)
python << endpython
import vim
import os
import tempfile

vim.command("up")
makeprg = vim.eval("&makeprg")
servername = vim.eval("v:servername")
args = vim.eval("a:args")
makeprg = vim.eval("expand(&makeprg)")

fd, tempfile = tempfile.mkstemp(prefix='vim-make')
os.close(fd)

def send_vim_cmd(s):
	return "vim --servername {servername} --remote-send '<esc>{cmd}'".format(servername=servername, cmd=s)

# surely there's a better way to do this
if "$*" in makeprg:
	makeprg = makeprg.replace("$*", args)
	args = ""

# I shudder to think what escaping is appropriate here...
cmd = "({makeprg} {args} > {filename} 2>&1 && {on_success} || {on_fail}; sleep 5; rm {filename} ) > /tmp/makelog &".format(
	filename=tempfile,
	makeprg=makeprg,
	args=args,
	on_fail = send_vim_cmd(":cgetfile {filename} | copen | echo \"Make failed.\"<cr>".format(filename=tempfile)),
	on_success = send_vim_cmd(":cclose | echo \"Make Succeeded!\"<cr>"),
)
vim.command("echo \"running make in the background...\"")
#print cmd
os.system(cmd)
endpython
endfun

command! -narg=? Make call <SID>BackgroundMake(<q-args>)
