; NOTE: requires:
;    apt-get install xbindkeys xautomation

; bind shift + vertical scroll to horizontal scroll events
;(xbindkey '(shift "b:4") "xte 'mouseclick 6'")
;(xbindkey '(shift "b:5") "xte 'mouseclick 7'")

; meta + scroll to resize major window
(xbindkey '(shift mod4 "b:4") "xte 'keyup Shift_L' 'key h' 'keydown Shift_L'")
(xbindkey '(shift mod4 "b:5") "xte 'keyup Shift_L' 'key l' 'keydown Shift_L'")
; meta + shift + scroll = resize minor window
(xbindkey '(alt mod4 "b:4") "xte 'keyup Alt_L' 'key u' 'keydown Alt_L'")
(xbindkey '(alt mod4 "b:5") "xte 'keyup Alt_L' 'key i' 'keydown Alt_L'")
; alt + scroll to switch tabs
(xbindkey '(alt "b:4") "xte 'keyup Alt_L' 'keydown Control_L' 'key Page_Up' 'keyup Control_L' 'keydown Alt_L'")
(xbindkey '(alt "b:5") "xte 'keyup Alt_L' 'keydown Control_L' 'key Page_Down' 'keyup Control_L' 'keydown Alt_L'")
; alt + meta + scroll to switch workspaces
(xbindkey '(mod4 "b:4") "xte 'key Page_Up'")
(xbindkey '(mod4 "b:5") "xte 'key Page_Down'")

(xbindkey '(release "b:8") "xte 'mouseclick 1' 'mouseclick 1'")

; I never use mod4+grave, unless my xkb bindings have been lost.
; So if I'm mashing this, it means I need to reset my keybindings
; (and maybe pther stuff too)
(xbindkey '(mod4 grave) "reset-all")


; ; left & right mouse buttons for changing tabs in most apps:
; (xbindkey '("b:8") "xte 'keydown Control_R' 'key Page_Up' 'keyup Control_R'")
; (xbindkey '("b:9") "xte 'keydown Control_R' 'key Page_Down' 'keyup Control_R'")
; 
; ; win + buttons = move focus
; (xbindkey '(mod4 "b:8") "xte 'key k'")
; (xbindkey '(mod4 "b:9") "xte 'key j'")
; 
; ; win + shift + buttons = move window
; (xbindkey '(shift mod4 "b:8") "xte 'key k'")
; (xbindkey '(shift mod4 "b:9") "xte 'key j'")
; 
; ; left & right for workspaces
; (xbindkey '(control alt "b:8") "xte 'key Left'")
; (xbindkey '(control alt "b:9") "xte 'key Right'")
; 
; ; alt + super + left/right click = add/decrease members in main area
; (xbindkey '(alt mod4 "b:8") "xte 'keyup Alt_L' 'str ,' 'keydown Alt_L'")
; (xbindkey '(alt mod4 "b:9") "xte 'keyup Alt_L' 'str .' 'keydown Alt_L'")
; 
; ; alt + buttons for workspace switching
; (xbindkey '(alt "b:8") "xte 'keyup Alt_L' 'keydown Super_L' 'key Page_Up'   'keyup Super_L' 'keydown Alt_L'")
; (xbindkey '(alt "b:9") "xte 'keyup Alt_L' 'keydown Super_L' 'key Page_Down' 'keyup Super_L' 'keydown Alt_L'")

;;TESTING...
;(xbindkey '(shift "c:94") "zenity --info")
;(xbindkey '(shift "c:94") "echo 1")
;(xbindkey '(shift "c:94") (lambda ())

; ctrl+m for enter
;(xbindkey '(control "c:58") "xvkbd -xsendevent -text '\\r'")
