import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

type Edge = tuple[w,dst:int]

proc asTree(E:seq[seq[Edge]]):seq[seq[Edge]] =
  var answer = newSeqWith(E.len,newSeq[Edge]())
  proc impl(pre,now:int) =
    for dst in E[now]:
      if dst.dst == pre : continue
      answer[now].add(dst)
      impl(now,dst.dst)
  impl(-1,0)
  return answer

let n = scan()
var E = newSeqWith(n,newSeq[Edge]())
(n-1).times:
  let u = scan() - 1
  let v = scan() - 1
  let w = scan()
  E[u].add((w,v))
  E[v].add((w,u))
E = E.asTree()
# echo E
var ans = newSeq[bool](n)
proc solve(now:int,isZero:bool) =
  ans[now] = isZero
  for dst in E[now]:
    solve(dst.dst,if dst.w mod 2 == 0: isZero else:not isZero)

solve(0,true)
for a in ans:
  echo(if a : 0 else: 1)
