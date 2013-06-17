set -x PATH \
	~/.bin/overrides \
	$PATH \
	/sbin/ \
	~/.cabal/bin \
	/usr/lib/nodejs/bin \
	~/bin \
	~/.bin

set NODE_PATH $NODE_PATH /usr/lib/nodejs/lib/node_modules
set FISH_CLIPBOARD_CMD "cat" # Stop that.
set BROWSER firefox
set -x EDITOR vim
set -x force_s3tc_enable true # games often need this

if [ -r ~/.aliasrc ]
	. ~/.aliasrc
end
alias ghost="sudo (which --skip-alias ghost)"
