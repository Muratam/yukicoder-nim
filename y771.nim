import sequtils,algorithm,math,tables
import sets,intsets,queues,heapqueue,bitops,strutils
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let AB = newSeqWith(n,(a:scan(),b:scan()))
let LR = AB.mapIt((l:it.a,r:it.b-it.a)).sortedByIt(it.l)
let L = LR.mapIt(it.l)
let R = LR.mapIt(it.r)
echo LR
for d in L.min()+R.min()..L.max()+R.max():
  echo d
  # 目標値 dとしてそれ以下で足し合わせていく
  var ok = true
  var l = LR[0].l
  var r = LR[0].r
  for i in 1..<n:
    if not ok: break
    let next = LR[i]
    let nlr = next.l + r
    let nrl = next.r + l
    if nlr > d:
      if nrl <= d: l = next.l
      else: ok = false
    else:
      if nrl > d: r = next.r
      else:
        if nrl < nlr: l = next.l
        else: r = next.r
  if ok:
    echo d
    quit 0
# let D = AB.sortedByIt(it.b - it.a)
# var ans = 0
# for i in 1..<n:
#   ans .max= D[i].a + (D[i-1].b - D[i-1].a)
# echo ans
# echo D