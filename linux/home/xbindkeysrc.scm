; NOTE: requires:
;    apt-get install xbindkeys xautomation

; bind shift + vertical scroll to horizontal scroll events
(xbindkey '(shift "b:4") "xte 'mouseclick 6'")
(xbindkey '(shift "b:5") "xte 'mouseclick 7'")

(xbindkey '("c:191") "songbird --pause")
(xbindkey '("m:0x48" "c:64" left) "songbird --previous")
(xbindkey '("m:0x48" "c:64" right) "songbird --next")

