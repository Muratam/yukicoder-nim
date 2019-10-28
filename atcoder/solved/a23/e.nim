{.checks:off.}
import algorithm

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
let n = scan()
let m = scan()
let l = scan()
type Edge = tuple[dst,cost:int]
var E = newSeqWith(n,newSeq[Edge]())
m.loop:
  let a = scan() - 1
  let b = scan() - 1
  let c = scan()
  # if c > l : continue # 無理な路
  E[a].add((b,c))
  E[b].add((a,c))


proc search(gsrc:int):seq[int] =
  var visited = newSeqWith(n,-1)
  var minLefts = newSeqWith(n,-1)
  var nowTime = 0
  var nows = @[gsrc]
  visited[gsrc] = 0
  while nows.len > 0:
    var nexts = newSeq[int]()
    var stack = newSeq[tuple[now,tank:int]]()
    # 行けるところまで行く
    for now in nows:
      stack.add((now,l))
    while stack.len > 0:
      let(now,tank) = stack.pop()
      for d in E[now]:
        let(dst,cost) = d
        let left = tank - cost
        if left < 0 : continue
        if visited[dst] < 0 :
          visited[dst] = nowTime
          nexts.add(dst)
        if minLefts[dst] < left:
          minLefts[dst] = left
          stack.add((dst,left))
    nows = nexts
    nowTime += 1
  return visited

let ans = toSeq(0..n-1).mapIt(search(it))
let q = scan()
q.loop:
  let src = scan() - 1
  let dst = scan() - 1
  echo ans[src][dst]
