import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
proc `^`(n:int) : int{.inline.} = (1 shl n)
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let m = scan()
# 電球mがつながっているswitch番号(0から)
var S = newSeq[seq[int]](m)
for i in 0..<m:
  let k = scan()
  S[i] = newSeqWith(k,scan()-1)
let P = newSeqWith(m,scan())
# 全探索すればいい
var ans = 0
for i in 0..<(^n):
  # スイッチの状態 が i
  var ok = true
  for mi in 0..<m:
    var num = 0
    for s in S[mi]:
      if (^s and i) > 0:
        num += 1
    if P[mi] != num mod 2 :
      ok = false
      break
  if ok : ans += 1
echo ans
