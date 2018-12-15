import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables
template get():string = stdin.readLine()
template times(n:int,body:untyped): untyped = (for _ in 0..<n: body)

let N = get().parseInt
let ws = get().split().map(parseInt)
let goal = ws.sum() div 2
var dp = newSeqWith(goal + 1,false)
dp[0] = true
for w in ws:
  for i in countdown(goal-w,0):
    if dp[i]: dp[i+w] = true
if ws.sum() mod 2 == 0 and dp[goal]:
  echo "possible"
else:
  echo "impossible"
#各wまでで dp[true] が可能な重さを表す
# 2^n な状態空間を 取りうる重さという1次空間にする
#自分の更新を反映しないようにcountdown