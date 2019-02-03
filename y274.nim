import sequtils,algorithm
template times*(n:int,body) = (for _ in 0..<n: body)



proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let m = scan()
var U = newSeq[bool](m)
let LR = newSeqWith(n,(l:scan(),r:scan()))
  .map(proc(x:tuple[l,r:int]):tuple[l,r:int] =
    if x.l < m-1-x.r: return x
    return (m-1-x.r,m-1-x.l)
  ).sortedByIt(it.l)
proc fill(l,r:int) : bool =
  for i in l..r:
    if U[i] : return false
  for i in l..r: U[i] = true
  return true
for lr in LR:
  let (l,r) = lr
  if fill(l,r) : continue
  if fill(m-r-1,m-l-1) : continue
  quit "NO",0
echo "YES"
