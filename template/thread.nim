
import sequtils,strutils,osproc;const p = @[ """echo '{.experimental.}

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
  let (a,b,t) = ABT[m].unpack(3)
  proc newton(a,b,t:float): float =
    result = 1.1
    var lnx = ln(result)
    for i in 1..25:
      result -= (a*lnx + b*lnx.ln - t.ln) / ((a*lnx + b) / (result*lnx))
      lnx = result.ln
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
for m in 0..<M:
  printf("%.9f\n",ans[m])


' > h.nim""","nim --hints:off -o:b.out -d:release --threads:on --experimental --parallelBuild:4 c h.nim"].mapIt(it.gorge)
#echo execProcess("./b.out").strip()
# IO バウンドかも
# parallel hello world # https://yukicoder.me/submissions/197995
# parallel echo # https://yukicoder.me/submissions/197997 (too yukicoder ...)

# discard startProcess("./repeat",options={
#   poEvalCommand,poUsePath,
#   poParentStreams,poInteractive,
#   poStdErrToStdOut,poEchoCmd
# }) # 上手く動作しない

#[
  yukicoder lscpu (KVM)
    Architecture:          x86_64
    CPU op-mode(s):        32-bit, 64-bit
    Byte Order:            Little Endian
    CPU(s):                4
    On-line CPU(s) list:   0-3
    Thread(s) per core:    1
    Core(s) per socket:    1
    Socket(s):             4
    NUMA node(s):          1
    Vendor ID:             GenuineIntel
    CPU family:            6
    Model:                 62
    Model name:            Intel(R) Xeon(R) CPU E5-2650 v2 @ 2.60GHz
    Stepping:              4
    CPU MHz:               2599.998
    BogoMIPS:              5199.99
    Virtualization:        VT-x
    Hypervisor vendor:     KVM
    Virtualization type:   full
    L1d cache:             32K
    L1i cache:             32K
    L2 cache:              256K
    L3 cache:              20480K
    NUMA node0 CPU(s):     0-3
]#