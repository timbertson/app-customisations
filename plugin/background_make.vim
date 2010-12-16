fun! <SID>BackgroundMake(args)
python << endpython
import vim
import os
import tempfile
import re

vim.command("up")
makeprg = vim.eval("&makeprg")
servername = vim.eval("v:servername")
args = vim.eval("a:args")
makeprg = vim.eval("expand(&makeprg)")

# can't figure out how to check for a variable's existance via python...
vim.command("""
if !exists('g:background_make_notify_cmd')
	let g:background_make_notify_cmd = ''
endif
""")
notify_cmd=vim.eval("g:background_make_notify_cmd")

if not notify_cmd:
	notify_cmd = 'notify-send "$msg" "Vim background make"'

fd, tempfile = tempfile.mkstemp(prefix='vim-make')
os.close(fd)

def send_vim_cmd(s):
	# The crazy loop is checking for a mode of either 'i' or 'n', because
	# that means we're not interrupting anything (the insert mode cursor
	# can be restored simply by pressing "a")
	return """while true; do
		mode=`vim --servername {servername} --remote-expr 'mode()'`;
		if [ "$mode" = "i" ]; then
			restore_mode="a"; break;
		fi;
		if [ "$mode" = "n" ]; then
			restore_mode=""; break;
		fi;
		sleep 0.2;
	done;
	vim --servername {servername} --remote-send '<esc>{cmd}'$restore_mode;"""\
	.format(servername=servername, cmd=s)

# surely there's a better way to do this
if "$*" in makeprg:
	makeprg = makeprg.replace("$*", args)
	args = ""

# expand all %:* filename specifiers individually, because
# vim's expand only does something useful when the string
# starts with "%"
file_exprs = re.findall(r'(?<!\\)(%(?::.)*)', makeprg)
for file_expr in sorted(file_exprs, key=lambda s:-len(s)):
	expanded = vim.eval("expand('%s')" % (file_expr,))
	makeprg = makeprg.replace(file_expr, expanded)

# I shudder to think what escaping is appropriate here...
cmd = """(
#set -x;
#sleep 5;
		if ({makeprg}) {args} > {filename} 2>&1; then
			msg='Success!';
			{on_success}
			({notify_cmd}) &
		else
			msg='Failed.';
			({notify_cmd}) &
			{on_fail}
		fi;
		sleep 5;
		rm {filename}
	) > /tmp/makelog 2>&1 &"""\
	.format(
		filename=tempfile,
		makeprg=makeprg,
		args=args,
		notify_cmd=notify_cmd,
		on_fail = send_vim_cmd(":cgetfile {filename} | copen | wincmd p | echo \"Make failed.\"<cr>".format(filename=tempfile)),

		on_success = send_vim_cmd(":cclose | echo \"Make Succeeded!\"<cr>"),
	)
vim.command("echo \"running make in the background...\"")
os.system(cmd)
#print cmd
#with open("/tmp/cmd", "w") as f:
#	f.write(cmd)

endpython
endfun

command! -narg=? Make call <SID>BackgroundMake(<q-args>)
