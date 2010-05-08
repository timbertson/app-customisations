-- modded bluetile config:
import XMonad.Hooks.ManageHelpers
import XMonad
import XMonad.Config.Bluetile
import XMonad.Util.Replace
import XMonad.Config.Gnome
main = replace >> xmonad bluetileConfig
	{ borderWidth = 2
	, normalBorderColor  = "#444444" -- "#dddddd"
	, focusedBorderColor = "#3399ff"	-- "#ff0000" don't use hex, not <24 bit safe
	, manageHook = manageHook gnomeConfig <+> myManageHook
	, focusFollowsMouse  = True
	, workspaces = ["1","2","3","4","5"]
-- 	-- , keys = customKeys delkeys inskeys
	}

myManageHook = composeAll [
	resource =? "desktop_window" --> doIgnore
	, className =? "/usr/lib/gnome-do/Do.exe" --> doIgnore
	, className =? "Do" --> doIgnore
	, className =? "Guake.py" --> doFloat
	, className =? "Zenity" --> doFloat
	, isFullscreen --> doFullFloat
	, isSplash --> doIgnore
	]
	where
		isSplash = isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_SPLASH"
