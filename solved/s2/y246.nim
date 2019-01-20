import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
# 1~10_0000_0000
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
var x = 1
var y = 10_0000_0010
while true:
  if x == y :
    echo "! ",x
    quit(0)
  let m = (x+y) div 2
  echo "? ",m
  let yes = getchar_unlocked() == '1'
  discard getchar_unlocked()
  if y - x == 1:
    if yes : echo "! ",x
    else: echo "! ",y
    quit(0)
  if yes: x = m
  else: y = m