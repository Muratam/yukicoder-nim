

proc longestIncreasingSubsequence[T](arr:seq[T],multi:bool) : int =
  var S = newTreapSet[T](true)
  for a in arr:
    # a より大きいものを一つ削除する
    let found = S.root.findGreater(a,not multi)
    if found != nil : S.erase found.key
    S.add a
  return S.len

import sequtils,algorithm,math,tables,sets,strutils,times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
template loop*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord
stopwatch:
  let n = scan()
  let A = newSeqWith(n,scan())
  echo A.longestIncreasingSubsequence(true)
