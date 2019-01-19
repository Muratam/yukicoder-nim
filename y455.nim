import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
type Pos = tuple[x,y:int]
proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
let h = scan()
let w = scan()
proc get():(Pos,Pos)=
  var a : Pos
  var aIsAlready = false
  for y in 0..<h:
    for x in 0..<w:
      if getchar_unlocked() != '*': continue
      if aIsAlready: return (a,(x,y))
      a = (x,y)
      aIsAlready = true
    discard getchar_unlocked()
let (a,b) = get()
var c:Pos
if a.x == b.x:
  if a.x == 0: c = (1,a.y)
  else: c = (a.x-1,a.y)
else:
  if a.y == 0: c = (a.x,1)
  else:c = (a.x,a.y-1)
proc encode(p:Pos):int = p.x + p.y * w
let codes = [a,b,c].map(encode)
var i = 0
for y in 0..<h:
  for x in 0..<w:
    if i in codes: putchar_unlocked('*')
    else: putchar_unlocked('-')
    i += 1
  putchar_unlocked('\n')