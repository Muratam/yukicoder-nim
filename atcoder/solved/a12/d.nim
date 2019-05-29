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

let n = scan() # 50
let k = scan() # 100
let V = stdin.readLine().split.map(parseInt) # n(=50) 個
var ans = 0
# 全探索
# 左 / 右 / 戻す を n 回まで
for l in 0..k:
  var my = newSeq[int]()
  for li in 0..<l:
    if li < V.len: my.add V[li]
  for r in 0..(k-l):
    if l-1 >= V.len-1-(r-1): continue
    var my2 = my
    for ri in 0..<r:
      if V.len-1-ri >= 0 : my2.add V[V.len-1-ri]
    if my2.len == 0 : continue
    # 最大 k-l-r 個戻せる
    my2.sort(cmp)
    for b in 0..<(k-l-r):
      if b >= my2.len : break
      if my2[b] < 0 : my2[b] = 0
    ans .max= my2.sum

echo ans
