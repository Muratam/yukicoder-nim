import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let k = scan() # k個食べる
# type
var kinds = newSeqWith(n+1,newSeq[int]())
n.times:
  let t = scan()
  let d = scan()
  kinds[t].add d
for i in 0..n: kinds[i].sort(cmp,Descending)
kinds.sort(proc(x,y:seq[int]):int =
  if x.len == 0 : return 1
  if y.len == 0 : return -1
  return - x[0] + y[0]
)
kinds = kinds.filterIt(it.len > 0)
echo kinds
proc eat(ik:int):int =
var ans = 0
for ik in 1..k.min(kinds.len()):
  let e = eat(ik)
  if e < 0 : continue
  ans .max= e
echo ans
# var answers = newSeq[int]()
# var leftNeed = 0
# var x = 0
# for i in 0..<k:
#   if i >= kinds.len or  kinds[i].len == 0 :
#     leftNeed = k - i
#     break
#   answers.add kinds[i][0]
#   x += 1
#   if kinds[i].len == 1 : kinds[i] = @[]
#   else: kinds[i] = kinds[i][1..^1]
# var lefts = newSeq[int]()
# for kind in kinds: lefts.add kind
# lefts.sort(cmp,Descending)
# # for i in 0..<leftNeed:
# echo lefts
# echo answers