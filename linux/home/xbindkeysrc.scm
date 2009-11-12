; NOTE: requires:
;    apt-get install xbindkeys xautomation

; bind shift + vertical scroll to horizontal scroll events
(xbindkey '(shift "b:4") "xte 'mouseclick 6'")
(xbindkey '(shift "b:5") "xte 'mouseclick 7'")

; f13 = play/pause
(xbindkey '("c:191") "songbird --pause")

; meta+alt+left/right for prev/next ( not yet working...)
(xbindkey '("m:0x48" "c:64" left) "songbird --previous")
(xbindkey '("m:0x48" "c:64" "c:0x") "songbird --next")

