-- modded bluetile config:
import XMonad.Hooks.ManageHelpers
import XMonad
import XMonad.Config.Bluetile
import XMonad.Util.Replace
import XMonad.Config.Gnome
import XMonad.Hooks.SetWMName
import XMonad.Hooks.ManageHelpers
import qualified XMonad.StackSet as W

main = replace >> xmonad bluetileConfig
	{ borderWidth = 2
	, normalBorderColor  = "#444444" -- "#dddddd"
	, focusedBorderColor = "#3399ff"	-- "#ff0000" don't use hex, not <24 bit safe
	, manageHook = manageHook gnomeConfig <+> myManageHook
	, focusFollowsMouse  = True
	, workspaces = ["1","2","3","4","5"]
	, startupHook = setWMName "LG3D" -- silly java...
-- 	-- , keys = customKeys delkeys inskeys
	}

myDoFullFloat :: ManageHook
myDoFullFloat = doF W.focusDown <+> doFullFloat

myManageHook = composeAll [
	resource =? "desktop_window" --> doIgnore
	, className =? "/usr/lib/gnome-do/Do.exe" --> doIgnore
	, className =? "Do" --> doIgnore
	, className =? "Guake.py" --> doFloat
	, className =? "Zenity" --> doFloat
	, className =? "Gloobus-preview" --> doFloat
	, isFullscreen --> myDoFullFloat
	, isSplash --> doIgnore
	]
	where
		isSplash = isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_SPLASH"
