import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
let n = scan()
let K = newSeqWith(n,scan())
type Win = tuple[a,b,c:int,win:bool]
proc isWin(K:seq[int]):Win =
  if K.len < 3 : return (0,0,0,false)
  var results = newSeq[Win]()
  for a in 0..<K.len:
    for b in (a+1)..<K.len:
      for c in (b+1)..<K.len:
        if K[a] == K[c] : continue
        if not ((K[a] < K[b] and K[b] > K[c]) or
                (K[a] > K[b] and K[b] < K[c])) : continue
        let K2 = K[0..<a] & K[a+1..<b] & K[b+1..<c] & K[c+1..<K.len]
        results &= (a,b,c,not isWin(K2).win)
  if results.len == 0: return (0,0,0,false)
  let wins = results.filterIt(it.win)
  if wins.len == 0 : return (0,0,0,false)
  return wins.sorted(proc(x,y:Win):int =
    if x.a != y.a : return x.a - y.a
    if x.b != y.b : return x.b - y.b
    return x.c - y.c
  )[0]
let win = K.isWin()
if not win.win: echo -1
else: echo win.a," ",win.b," ",win.c
