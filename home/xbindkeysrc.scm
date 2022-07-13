; alt + scroll to switch tabs
(xbindkey '(alt "b:4") "xte 'keyup Alt_L' 'keydown Control_L' 'key Page_Up' 'keyup Control_L' 'keydown Alt_L'")
(xbindkey '(alt "b:5") "xte 'keyup Alt_L' 'keydown Control_L' 'key Page_Down' 'keyup Control_L' 'keydown Alt_L'")

(xbindkey '(shift "b:4") "xte 'keyup Shift_L' 'keydown Control_L' 'key Page_Up' 'keyup Control_L' 'keydown Shift_L'")
(xbindkey '(shift "b:5") "xte 'keyup Shift_L' 'keydown Control_L' 'key Page_Down' 'keyup Control_L' 'keydown Shift_L'")

; use mac-style tab swiching
(xbindkey '(control shift bracketleft ) "xte 'keyup bracketleft'  'keyup Shift_L' 'key Page_Up'   'keydown Shift_L'")
(xbindkey '(control shift bracketright) "xte 'keyup bracketright' 'keyup Shift_L' 'key Page_Down' 'keydown Shift_L'")


; alt + meta + scroll to switch workspaces
(xbindkey '(mod4 "b:4") "xte 'key Page_Up'")
(xbindkey '(mod4 "b:5") "xte 'key Page_Down'")

(xbindkey '(release "b:8") "xte 'mouseclick 1' 'mouseclick 1'")
