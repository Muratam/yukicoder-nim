import sequtils,strutils,algorithm,math,future,macros
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)

# t , n^a (log n)^b 秒
# 53_300k_1.txt -> 1600 ms (parallel::3003ms... -> 1705ms)
proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc scan3f():seq[float] =
  var a,b,c : float
  scanf("%lf%lf%lf",addr a,addr b,addr c)
  return @[a,b,c].mapIt(it)
let
  M = get().parseInt()
  ABT = newSeqWith(M,scan3f())
var ans = newSeq[float](M)

proc solve(m:int) =
  proc newton(a,b,t:float): float =
    result = 1.1
    var lnx = ln(result)
    for i in 1..25:
      result -= (a*lnx + b*lnx.ln - t.ln) / ((a*lnx + b) / (result*lnx))
      lnx = result.ln
  let (a,b,t) = ABT[m].unpack(3)
  ans[m] = if a == 0: exp(pow(t, 1.0/b))
        elif b == 0: pow(t, 1.0/a)
        else: newton(a,b,t)

template parallelDo(fn:int->void ,MIN,MAX:int) =
  # do fn(i) parallel :: i in [MIN..<MAX]
  import cpuinfo,threadpool
  let STEP = max(1,(MAX - MIN) div countProcessors())
  proc solveProc(m:int) = (for mi in m..< min(m+STEP,M): fn(mi))
  for m in countup(MIN,MAX,STEP):
    spawn solveProc(m)
  sync()

parallelDo(solve,0,M)
for m in 0..<M: printf("%.9f\n",ans[m])

#[
{.experimental.}
import threadpool
import sequtils,strutils,algorithm,math,future,macros
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)

# t , n^a (log n)^b 秒
# 53_300k_1.txt -> 1600 ms
let
  M = get().parseInt()
  ABT = newSeqWith(M,get().split().map(parseFloat))
proc solve(m:int): float =
  let (a,b,t) = ABT[m].unpack(3)
  proc newton(): float =
    result = 1.1
    var lnx = ln(result)
    for i in 1..25:
      result -= (a*lnx + b*lnx.ln - t.ln) / ((a*lnx + b) / (result*lnx))
      lnx = result.ln
  return if a == 0: exp(pow(t, 1.0/b))
          elif b == 0: pow(t, 1.0/a)
          else: newton()
proc main() =
  var ans = newSeq[float](M)
  #parallel:
  #  for m in 0..ans.high:
  #    ans[m] = spawn solve(m)
  for m in 0..ans.high:
    ans[m] = solve(m)
  for m in 0..<M:
    echo(($ans[m])[0..11])
main()
]#