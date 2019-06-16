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


# proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
# proc scan(): int = scanf("%lld\n",addr result)
# echo toSeq(0..10)
# echo toSeq("123".items)
let n = scan()
var E = newSeqWith(n,newSeq[int]())
(n-1).times:
  let a = scan() - 1
  let b = scan() - 1
  E[a] .add b
  E[b] .add a
E = E.asTree()
let C = newSeqWith(n,scan()).sorted(cmp)
echo E
echo C
