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

if [ -r ~/.aliasrc ]
	. ~/.aliasrc
end
