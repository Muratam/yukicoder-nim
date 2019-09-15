import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues,times
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord


proc countSetBits(n: uint64): int {.inline, noSideEffect.} =
  var v = uint64(n)
  v = v - ((v shr 1'u64) and 0x5555555555555555'u64)
  v = (v and 0x3333333333333333'u64) + ((v shr 2'u64) and 0x3333333333333333'u64)
  v = (v + (v shr 4'u64) and 0x0F0F0F0F0F0F0F0F'u64)
  result = ((v * 0x0101010101010101'u64) shr 56'u64).int

proc popcount*(x: SomeInteger): int {.inline, nosideeffect.} =
  result = countSetBits(x)
const randMax = 18_446_744_073_709_551_615u64
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
# 半分毎のグループに分けて、 xorsum{}+xorsum{}
let n = scan()
var A = newSeqWith(n,scan())
# let tStart = cpuTime()
var theSum = 0
# while cpuTime() - tStart < 1.8:
#   shuffle(A)
block:
  A = A.sortedByIt(it)
  var sumX = 0
  var sumY = 0
  for a in A:
    if ((sumX xor a) >= sumX) and ((sumY xor a) <= sumY):
      sumX = sumX xor a
    elif ((sumY xor a) >= sumY) and ((sumX xor a) <= sumX):
      sumY = sumY xor a
    else: # xor すると同じくらい大きくなったり小さくなったり
      let xa = (sumX xor a) + sumY
      let ya = sumX + (sumY xor a)
      if xa < ya:
        sumY = sumY xor a
      elif xa > ya:
        sumX = sumX xor a
      else:
        let xp =  popcount((sumX xor a).uint64)
        let yp =  popcount((sumY xor a).uint64)
        if xp > yp:
          sumX = sumX xor a
        else:
          sumY = sumY xor a

  theSum .max= sumX + sumY
echo theSum
