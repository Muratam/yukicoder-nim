
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


import os except sleep
import posix, parseutils
template daemonize*(pidfile, si, so, se, cd: string,body: stmt): stmt {.immediate.} =
  var
    pid: Pid
    pidFileInner: string
    fi, fo, fe: File
  proc c_signal(sig: cint, handler: proc (a: cint) {.noconv.}) {.importc: "signal", header: "<signal.h>".}
  proc onStop(sig: cint) {.noconv.} =
    close(fi)
    close(fo)
    close(fe)
    removeFile(pidFileInner)
    quit(QuitSuccess)
  if fileExists(pidfile):
    raise newException(IOError, "pidfile " & pidfile & " already exist, daemon already running?")
  pid = fork()
  if pid > 0:
    quit(QuitSuccess)
  if cd != nil and cd != "":
    discard chdir(cd)
  discard setsid()
  discard umask(0)
  pid = fork()
  if pid > 0:
    quit(QuitSuccess)
  flushFile(stdout)
  flushFile(stderr)
  if not si.isNil and si != "":
    fi = open(si, fmRead)
    discard dup2(getFileHandle(fi), getFileHandle(stdin))
  if not so.isNil and so != "":
    fo = open(so, fmAppend)
    discard dup2(getFileHandle(fo), getFileHandle(stdout))
  if not se.isNil and se != "":
    fe = open(se, fmAppend)
    discard dup2(getFileHandle(fe), getFileHandle(stderr))
  pidFileInner = pidfile
  c_signal(SIGINT, onStop)
  c_signal(SIGTERM, onStop)
  c_signal(SIGHUP, onStop)
  c_signal(SIGQUIT, onStop)
  pid = getpid()
  writeFile(pidfile, $pid)
  body

daemonize("/tmp/daemonize.pid", "/dev/null", "/tmp/daemonize.out", "/tmp/daemonize.err", "/"):
  discard execProcess("""a="$(ls -1t ../time/ | head -1)";./b.out < ../test_in/$a > ../out/$a """)
#echo execProcess("./b.out").strip()
# IO バウンドかも
# parallel hello world # https://yukicoder.me/submissions/197995
# parallel echo # https://yukicoder.me/submissions/197997 (too yukicoder ...)

# discard startProcess("./repeat",options={
#   poEvalCommand,poUsePath,
#   poParentStreams,poInteractive,
#   poStdErrToStdOut,poEchoCmd
# }) # 上手く動作しない

