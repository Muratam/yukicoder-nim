import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
iterator reversedIterator[T](arr:openArray[T]) : T =
  for i in (arr.len - 1).countdown(0): yield arr[i]

const MOD = 1e9.int + 7
let S = stdin.readLine() # 1e5
# 13 で割って 5 余る数
var dp13 = newSeq[int](13) # 現時点で13で割った場合のあまりのかず
dp13[0] = 1
var rad = 1
proc getNext(pre:seq[int],c:int):seq[int] =
  result = newSeq[int](13)
  let nc = (c * rad) mod 13
  for i in 0..<13:
    result[(i + nc) mod 13] = pre[i]

for s in S.reversedIterator():
  if s == '?':
    let pre = dp13
    dp13 = newSeq[int](13)
    for q in 0..9:
      let next = pre.getNext(q)
      for i in 0..<13:
        dp13[i] = (dp13[i] + next[i]) mod MOD
  else:
    dp13 = dp13.getNext(s.ord - '0'.ord)
  rad = (rad * 10) mod 13
echo dp13[5]
