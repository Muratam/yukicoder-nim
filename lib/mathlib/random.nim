
# nim 0.13 にはランダムが無いのでコンパイルが通るやつを置いておく
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
    let j = random(i.uint64).int
    swap(x[i], x[j])

import times
template randomSearch[T](arr:var openArray[T],milliSec:int,body) =
  let startTime = cpuTime()
  while (cpuTime() - startTime) * 1000 < milliSec:
    body
    shuffle(arr)

when isMainModule:
  import unittest
  test "random":
    for i in 0..<100:
      check: random(2) <= 1 and 0.uint64 <= random(2)
