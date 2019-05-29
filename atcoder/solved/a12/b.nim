import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
type SPType = tuple[town:string,index:int,point:int]
var spSeq =newSeq[SPType]()
for i in 1..n:
  let S = stdin.readLine.split()
  let s = S[0]
  let p = S[1].parseInt()
  spSeq.add((s,i,p))
spSeq.sort(proc(x,y:SPType):int =
    if x.town != y.town:
      return cmp(x.town,y.town)
    return y.point - x.point
  )
for s in spSeq:
  echo s.index

