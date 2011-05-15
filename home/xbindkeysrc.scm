; NOTE: requires:
;    apt-get install xbindkeys xautomation

; bind shift + vertical scroll to horizontal scroll events
(xbindkey '(shift "b:4") "xte 'mouseclick 6'")
(xbindkey '(shift "b:5") "xte 'mouseclick 7'")

; left & right mouse buttons for changing tabs in most apps:
(xbindkey '("b:8") "xte 'keydown Control_R' 'key Page_Up' 'keyup Control_R'")
(xbindkey '("b:9") "xte 'keydown Control_R' 'key Page_Down' 'keyup Control_R'")

; shift + buttons = move focus
(xbindkey '(mod4 "b:8") "xte 'key k'")
(xbindkey '(mod4 "b:9") "xte 'key j'")

; control + shift + buttons = move window
(xbindkey '(shift mod4 "b:8") "xte 'key k'")
(xbindkey '(shift mod4 "b:9") "xte 'key j'")

; left & right for workspaces
(xbindkey '(control alt "b:8") "xte 'key Left'")
(xbindkey '(control alt "b:9") "xte 'key Right'")

; meta + scroll to resize major window
(xbindkey '(mod4 "b:4") "xte 'key h'")
(xbindkey '(mod4 "b:5") "xte 'key l'")

; meta + shift + scroll = resize minor window
(xbindkey '(shift mod4 "b:4") "xte 'keyup Shift_L' 'key u' 'keydown Shift_L'")
(xbindkey '(shift mod4 "b:5") "xte 'keyup Shift_L' 'key i' 'keydown Shift_L'")

; alt + super + left/right click = add/decrease members in main area
(xbindkey '(alt mod4 "b:8") "xte 'keyup Alt_L' 'str ,' 'keydown Alt_L'")
(xbindkey '(alt mod4 "b:9") "xte 'keyup Alt_L' 'str .' 'keydown Alt_L'")

; alt + buttons for workspace switching
(xbindkey '(alt "b:8") "xte 'keyup Alt_L' 'keydown Super_L' 'key Page_Up'   'keyup Super_L' 'keydown Alt_L'")
(xbindkey '(alt "b:9") "xte 'keyup Alt_L' 'keydown Super_L' 'key Page_Down' 'keyup Super_L' 'keydown Alt_L'")

; new terminal on ctrl+alt+return
(xbindkey '(control alt "c:36") "gnome-terminal")

; kill windows with meta+shift+middle-click
(xbindkey '(alt mod4 "b:2") "xte 'keyup Alt_L' 'keydown Shift_L' 'key c' 'keyup Shift_L' 'keydown Alt_L'")

; ctrl+m for enter
;(xbindkey '(control "c:58") "xvkbd -xsendevent -text '\\r'")
