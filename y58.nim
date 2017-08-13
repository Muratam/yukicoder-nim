import sequtils,strutils,strscans,algorithm,math,future,macros
template get*():string = stdin.readLine() #.strip()
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)

proc probAdd(ps,qs:seq[float]):seq[float] =
  result = newSeqWith(ps.len + qs.len - 1,0.0)
  for i,p in ps:
    for j,q in qs:
      result[i + j] += p * q

proc prob(base:seq[float],n:int): seq[float] =
  result = @[1.0]
  n.times: result = probAdd(result,base)

# K:445566 N-K:123456 => P(Win) | sum: 大きい方が勝ち / 同じなら引き分け
let
  N = get().parseInt() # < 10
  K = get().parseInt()
let
  ps  = toSeq(0..6).mapIt(if it >= 1 : 1.0/6.0 else: 0.0).prob(N)
  qs1 = toSeq(0..6).mapIt(if it >= 4 : 1.0/3.0 else: 0.0).prob(K)
  qs2 = toSeq(0..6).mapIt(if it >= 1 : 1.0/6.0 else: 0.0).prob(N-K)
  qs  = qs1.probAdd(qs2)
var ans = 0.0
for i,p in ps:
  for j,q in qs:
    if j > i : ans += p * q
echo ans