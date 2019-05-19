import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
# template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc `^`(n:int) : int{.inline.} = (1 shl n)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

proc asTree(E:seq[seq[int]]):seq[seq[int]] =
  var answer = newSeqWith(E.len,newSeq[int]())
  proc impl(pre,now:int) =
    for dst in E[now]:
      if dst == pre : continue
      answer[now].add(dst)
      impl(now,dst)
  impl(-1,0)
  return answer


let n = scan()
let k = scan()
var T = newSeq[int]()
for i in 1..n:
  var x = i
  var t = 0
  while true:
    if x >= k : break
    x = x * 2
    t += 1
  T.add t
# echo T
var tm = T.max()
var ans = 0
for t in T:
  ans += ^(tm - t)
echo( ans / ^tm / n.float)

# 1/n * ( (1/2)^t + (1/2)^t + ... )
