import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord

# (親も子も同一視して)双方向になっている木を,0 番を根として子のノードだけ持つように変更する
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
var E = newSeqWith(n,newSeq[int]())
(n-1).times:
  let a = scan() - 1
  let b = scan() - 1
  E[a].add b
  E[b].add a
E = E.asTree()
# 極小な木と0に注意
# k in {1,2} / n in {1}
const MOD = 1000000007
var ans = 1
# 幅優先探索
proc solve(now:int,initial:int) =
  if initial <= 0: # 濡れなくなった
    echo 0
    quit 0
  ans = (ans * initial) mod MOD
  var x = max(initial - 1,k-2)
  for dst in E[now]:
    solve(dst,x)
    x -= 1

solve(0,k)
echo ans
