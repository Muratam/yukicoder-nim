import sequtils
# 定数倍が軽いPriority Queue
# 制約 : 最後にpopした値よりも小さな値を入れられない
# O(logD)
type RadixHeap[T] = ref object
  size,last: int
  avalableMin:int
  when T is void: data: seq[seq[int]]
  else: data: seq[seq[tuple[k:int,v:T]]]
proc countLeadingZeroBits(x: culonglong): cint {.importc: "__builtin_clzll", cdecl.}
# 非負整数範囲版
proc newRadixHeap*[T](avalableMin:int = 0):RadixHeap[T] =
  new(result)
  result.size = 0
  result.last = 0
  result.avalableMin = avalableMin
  when T is void:
    result.data = newSeqWith(64,newSeq[int]())
  else:
    result.data = newSeqWith(64,newSeq[tuple[k:int,v:T]]())
# 全範囲版 (定数倍が重たい)
proc newAllRangeRadixHeap*[T]():RadixHeap[T] =
  newRadixHeap[T](-1152921504606846976.int)
proc len*[T](self:RadixHeap[T]) : int = self.size
proc getBit(x:int):int =
  if x > 0 : return 64 - cast[culonglong](x).countLeadingZeroBits()
  return 0
proc push*(self:RadixHeap[void],key:int) =
  self.size += 1
  let key = key - self.avalableMin
  let last = self.last
  let bit = getBit(key xor last)
  self.data[bit].add key
proc top*(self:RadixHeap[void]) : int =
  if self.data[0].len > 0:
    return self.data[0][^1]
  var i = 1
  while self.data[i].len == 0 : i += 1
  self.last = self.data[i][0]
  for j in 1..<self.data[i].len:
    if self.data[i][j] < self.last:
      self.last = self.data[i][j]
  for d in self.data[i]:
    self.data[getBit(d xor self.last)].add d
  self.data[i].setLen(0)
  return self.data[0][^1] + self.avalableMin
proc pop*(self:RadixHeap[void]) : int {.discardable.} =
  result = self.top()
  self.size -= 1
  discard self.data[0].pop()

when isMainModule:
  import unittest
  import times
  import "../../mathlib/random"
  test "Radix Heap":
    var R = newRadixHeap[void]()
    for x in @[43,23,43,44,11,130,20]:
      R.push(x)
    var last = -1e12.int
    while R.len > 0:
      let p = R.pop()
      echo p
      check: last <= p
      last = p
  if true:
    template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
    stopwatch:
      let n = 1e6.int
      var S = newAllRangeRadixHeap[void]()
      for _ in 0..n: S.push randomBit(32)
      S.pop()
      for _ in 0..n-10: S.pop()
      echo S.pop()
