import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables,macros
macro unpack*(rhs: seq,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `rhs`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template get*():string = stdin.readLine()
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template `max=`*(x,y:typed):void = x = max(x,y)
template `min=`*(x,y:typed):void = x = min(x,y)


const INF = 1e10.int
let
  N = get().parseInt #~50
  S = newSeqWith(N,get().parseInt) # 滞在コスト ~1000
  M = get().parseInt # ~N^2/2
  ABC = newSeqWith(M,get().split().map(parseInt)) # A->B にコスト C

# ワーシャルフロイド => A->Bの距離がわかる
# A,Bに滞在するとして 0->A->B->Nの最低コストが解
var a2b = newSeqWith(N,newSeqWith(N,INF))
for abc in ABC:
  let (a,b,c) = abc.unpack(3)
  a2b[a][b] = c
  a2b[b][a] = c

for k in 0..<N:
  for i in 0..<N:
    for j in 0..<N:
      a2b[i][j] .min= a2b[i][k] + a2b[k][j]

var res = INF
for a in 1..<N-1:
  for b in 1..<N-1:
    if a == b : continue
    res .min= a2b[0][a] + a2b[a][b] + a2b[b][N-1] + S[a] + S[b]

echo res