import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues,times
# heapqueue,bitops,strformat,sugar cannot use
# template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc scan(): int = scanf("%lld\n",addr result)
type Pos = tuple[x,y:int]
proc abs(p:Pos):int = p.x*p.x+p.y*p.y
proc `+`(a,b:Pos):Pos = (a.x+b.x,a.y+b.y)

type
  Rand* = object
    a0, a1: uint64
var state = Rand(
  a0: 0x69B4C98CB8530805u64,
  a1: 0xFED1DD3004688D67CAu64)
proc rotl(x, k: uint64): uint64 =
  result = (x shl k) or (x shr ((64).uint64 - k))
proc next*(r: var Rand): uint64 =
  let s0 = r.a0
  var s1 = r.a1
  result = s0 + s1
  s1 = s1 xor s0
  r.a0 = rotl(s0, 55) xor s1 xor (s1 shl 14) # a, b
  r.a1 = rotl(s1, 36) # c
proc random*(maxI: uint64): uint64 =
  while true:
    let x = next(state)
    return x mod maxI
proc shuffle*[T](x: var openArray[T]) =
  for i in countdown(x.high, 1):
    let j = random(i)
    swap(x[i], x[j])

let tStart = cpuTime()
let n = scan()
let XY = newSeqWith(n,(x:scan(),y:scan()))
var ans = 0
while cpuTime() - tStart < 0.8:
  var S = toSeq(0..n-1)
  shuffle(S)
  for i in 0..<n:
    var tmp : Pos = XY[S[i]]
    for j in (i+1)..<n:
      if tmp.abs < (tmp+XY[S[j]]).abs:
        tmp = tmp + XY[S[j]]
    ans .max= tmp.abs

echo ans.float.sqrt()
# echo cpuTime() - tStart
