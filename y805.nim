import sequtils,times
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let S = stdin.readLine()
stopwatch:
  var U = newSeqOf[int](n)
  var ans = 0
  for i in 0..<n:
    if S[i] == 'G' : continue
    if S[i] == 'U':
      U &= i
      continue
    # M
    for ui in (U.len-1).countdown(0):
      let gi = i - U[ui] + i
      if gi >= n : break
      if S[gi] == 'G' : ans += 1
  echo ans
