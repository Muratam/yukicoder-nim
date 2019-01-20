import sequtils,strutils,algorithm,math,future,macros
template get*():string = stdin.readLine().strip()
template `max=`*(x,y:typed):void = x = max(x,y)

let
  T = get().parseInt() # < 10000
  N = get().parseInt() # < 15
  C = get().split().map(parseInt) # < 100 # 残り時間
  V = get().split().map(parseInt) # < 500 # 満足度
# 二回目以降は v div 2
var dp = newSeqWith(T+1,0) # 残り時間 T
for i in 0..<N:
  var (cost,satis) = (C[i],V[i])
  while satis > 0:
    for t in cost..T:
      dp[t-cost] .max= dp[t] + satis
    satis = satis div 2
echo dp[0]
#@[7, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]