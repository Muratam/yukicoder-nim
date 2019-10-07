import sequtils,algorithm,math,tables,sets,strutils,times
proc RHP(hash:int,c:char): int =
  (hash * 10007 + c.ord) mod 1000000000000037
proc RH(S:string):int =
  for c in S: result = result.RHP(c)

template time*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord

let S = stdin.readLine()
let m = scan()
var P = newSeq[string](m)
# DP は maxPLenの長さまですればいける
var maxPLen = 0
for i in 0..<m:
  P[i] = stdin.readLine()
  maxPLen .max= P[i].len
# 文字サイズ -> 文字index
var table = newSeqWith(maxPLen+2,newSeq[int]())
# 文字index -> ハッシュ
var H = newSeq[int](m)
for i in 0..<m:
  table[P[i].len].add i
  H[i] = P[i].RH()
let W = newSeqWith(m,scan())
var dp = newSeq[int](S.len+1)
for i in 0..<S.len:
  var h = 0
  for l in 1..<table.len:
    if i+l >= dp.len: break
    h = h.RHP(S[i+l])
    for pi in table[l]:
      if h != H[pi]: continue
      dp[i+l] .max= dp[i] + W[pi]
  dp[i+1] .max= dp[i]
# echo dp
echo dp[^1]
