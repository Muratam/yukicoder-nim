import sequtils,strutils,times
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
template times*(n:int,body) = (for _ in 0..<n: body)
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' : return
    result = 10 * result + k.ord - '0'.ord
proc fputs(c: cstring, f: File) {.importc: "fputs", header: "<stdio.h>",tags: [WriteIOEffect].}
template put(c:untyped) = fputs(cstring(c),stdout)
proc funlockfile(f:File) {.importc: "funlockfile", header:"<stdio.h>" .}

stdout.write "A="
let n = scan()
var Q = newSeq[string]()
if n == 1:
  2.times:
    let q = scan()
    let r = scan()
    if r == 0 : continue
    if q == 0 : Q &= "(¬P_1)"
    else: Q &= "(P_1)"
else:
  stopwatch:
    var arr = newSeq[int](n)
    (1 shl n).times:
      for i in 0..<n: arr[i] = scan()
      if scan() == 0 : continue
      var s = "("
      if arr[0] == 0 : s &= "¬P_1"
      else: s &= "P_1"
      for j in 1..<n:
        if arr[j] == 0: s &= "∧¬P_"
        else: s &= "∧P_"
        if j+1 < 10: s &= ('0'.ord + (j+1).ord).chr
        else:
          s &= '1'
          s &= ('0'.ord + (j+1-10).ord).chr
      s &= ')'
      Q &= s
if Q.len == 0 : quit "⊥",0
if Q.len == 1 shl n : quit "⊤",0

put Q[0]
stopwatch:
  for i in 1..<Q.len:
    put "∨"
    put Q[i]
  put "\n"
