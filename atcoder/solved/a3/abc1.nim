import sequtils,strutils,algorithm,math,future,macros,sets,tables,intsets,queues
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let _t = get().split().map(parseInt)
let (m,n,s,t) = (_t[0],_t[1],_t[2]-1,_t[3]-1)
var to = newSeqWith(n,newSeqWith(n,(-1,-1)))
for i in 0..<m:
  let _t = get().split().map(parseInt)
  to[u][v] = (a,b)
  to[v][u] = (a,b)

