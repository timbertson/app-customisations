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

; f13 = play/pause
;(xbindkey '("c:191") "songbird --pause")
; f14 & f15 for prev/next
;(xbindkey '("c:193") "songbird --next")
;(xbindkey '("c:192") "songbird --previous")

; meta+alt+left/right for prev/next ( not yet working...)
;(xbindkey '("m:0x48" "c:64" left) "songbird --previous")
;(xbindkey '("m:0x48" "c:64" "c:0x") "songbird --next")

