background-make
---------------
It's not perfect, but for non-pathological `makeprg` settings it seems to work very reliably. It adds a `:Make` command that does exactly what `:make` does, except it does it in the background.

And it tries its very best to not disrupt you - by default, it'll send a system notification the moment that `make` finishes. But it will then wait until you are in either insert or normal mode, at which point it'll take the opportunity to pop up the error window and restore your cursor position / mode.

Using:
------

When you would use `:make`, use `:Make` instead. Simple!

Customising:
------------

currently the only settable option is changing the notification
command, by setting `g:background_make_notify_cmd`

The default value is:

	notify-send "$msg" "Vim background make"

`$msg` will be substitited at run time for either "Success!" or "Failed.".
If you don't want any notifications, you can simply set it to "echo" or
something similarly ineffectual.
