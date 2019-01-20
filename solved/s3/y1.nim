import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables
template get():string = stdin.readLine()
template times(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template `max=`(x,y:typed):void = x = max(x,y)
template `min=`(x,y:typed):void = x = min(x,y)

const INF = 1e14.int
let
  N = get().parseInt # towns
  CMAX = get().parseInt # coins
  PATH = get().parseInt # pathes
  # s->t に コストy m時間 || 1 -> N に C円以内で最小の時間
  S = get().split().map(parseInt) # 1 ~ N   start
  T = get().split().map(parseInt) # s ~ N   terminate
  C = get().split().map(parseInt) # 1..CMAX  cost
  L = get().split().map(parseInt) # 1..1000 length

# N:50 c:300 => 15000
# town,cost -> length
var dp = newSeqWith(N+1,newSeqWith(CMAX+1,INF))
dp[1][0] = 0
var STCL = toSeq(0..<PATH).mapIt((S[it],T[it],C[it],L[it]))
STCL.sort((a,b) => a[0] - b[0])
for stcl in STCL:
  let (s,t,c,l) = stcl
  for ci in 0..CMAX-c+1:
    dp[t][ci+c].min= dp[s][ci] + l

var res = dp[N].min()
if res == INF: res = -1
echo res