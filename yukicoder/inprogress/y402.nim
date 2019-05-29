import sequtils
# import algorithm,math,tables
# import times,macros,queues,bitops,strutils,intsets,sets
# import rationals,critbits,ropes,nre,pegs,complex,stats,heapqueue,sugar
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
# template stopwatch(body) = (let t1 = cpuTime();body;echo "TIME:",(cpuTime() - t1) * 1000,"ms")
# template `^`(n:int) : int = (1 shl n)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let h = scan()
let w = scan()
var C = newSeqWith(w,newSeq[bool](h))
for y in 0..<h:
  for x in 0..<w:
    C[x][y] = getchar_unlocked() == '#'
  discard getchar_unlocked()
var D = newSeqWith(w,newSeqWith(h,-1))
for y in 0..<h:
  for x in 0..<w:
    if not C[x][y] : D[x][y] = 0
for y in 0..<h:
  for x in [0,w-1]:
    if D[x][y] == -1 : D[x][y] = 1
for x in 0..<w:
  for y in [0,h-1]:
    if D[x][y] == -1 : D[x][y] = 1

proc fill(x,y,r:int) =
  if D[x][y] != -1 : return


for x in 1..<w-1:
  for y in 1..<h-1:
    fill(x,y)
