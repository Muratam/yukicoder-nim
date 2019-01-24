import sequtils,math
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

const INF = 1000_0010
const C = (proc():seq[int] =
  result = @[]
  for i in 1..INF:
    let c = i * (i + 1) div 2
    if c > INF : break
    result &= c
)()
proc isTriangleNum(n:int) : bool =
  let nsq = (n*2).float.sqrt.int
  return nsq * (nsq + 1) div 2 == n

let n = scan()
if n.isTriangleNum() : quit "1",0
for c in C:
  if c > n: break
  if (n-c).isTriangleNum(): quit "2",0
echo 3