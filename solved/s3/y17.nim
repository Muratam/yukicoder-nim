import sequtils
template times*(n:int,body) = (for _ in 0..<n: body)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

const INF = 1e10.int
let n = scan()
let S = newSeqWith(n,scan())
let m = scan()
var E = newSeqWith(n,newSeqWith(n,INF))
m.times:
  let src = scan()
  let dst = scan()
  let cost = scan()
  E[src][dst] = cost
  E[dst][src] = cost

# ワーシャルフロイド => A->Bの全ての距離がわかる
# A,Bに滞在するとして 0->A->B->Nの最低コストが解
var ans = INF
for k in 0..<n:
  for i in 0..<n:
    for j in 0..<n:
      E[i][j] .min= E[i][k] + E[k][j]

var res = INF
for a in 1..<n-1:
  for b in 1..<n-1:
    if a == b : continue
    ans .min= E[0][a] + E[a][b] + E[b][n-1] + S[a] + S[b]

echo ans