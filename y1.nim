import sequtils,algorithm,sugar
template `min=`(x,y:typed):void = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

const INF = 1e14.int
type Edge = tuple[src,dst,cost,len:int]

let n = scan()
let maxCost = scan()
let v = scan()
var E = newSeq[Edge](v)
for i in 0..<v: E[i].src = scan()
for i in 0..<v: E[i].dst = scan()
for i in 0..<v: E[i].cost = scan()
for i in 0..<v: E[i].len = scan()
E.sort((x,y) => x.src - y.src)
var dp = newSeqWith(n+1,newSeqWith(maxCost+1,INF))
dp[1][0] = 0
for e in E:
  for ci in 0..(maxCost-e.cost):
    dp[e.dst][ci+e.cost] .min= dp[e.src][ci] + e.len
let ans = dp[n].min()
if ans == INF: echo -1
else: echo ans