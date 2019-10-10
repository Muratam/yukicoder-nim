import sequtils
# 定数倍が軽いPriority Queue. 2倍くらい速い
# 制約 : 最後にpopした値よりも小さな値を入れられない
# O(logD)
# ダイクストラとかが高速化できる
type KeyValue[T] = tuple[key:int,value:T]
type RadixHeap[T] = ref object
  size,last: int
  avalableMin:int
  saveMin:bool
  when T is void: data: seq[seq[int]]
  else: data: seq[seq[KeyValue[T]]]
proc countLeadingZeroBits(x: culonglong): cint {.importc: "__builtin_clzll", cdecl.}
# 非負整数範囲版
proc newRadixHeap*[T](avalableMin:int = 0):RadixHeap[T] =
  new(result)
  result.size = 0
  result.last = 0
  result.avalableMin = avalableMin
  result.saveMin = true
  when T is void:
    result.data = newSeqWith(64,newSeq[int]())
  else:
    result.data = newSeqWith(64,newSeq[KeyValue[T]]())
# 全範囲版(ほんのり速度が落ちる)
proc newAllRangeRadixHeap*[T](saveMin:bool):RadixHeap[T] =
  result = newRadixHeap[T](-1152921504606846976.int)
  result.saveMin = saveMin
proc len*[T](self:RadixHeap[T]) : int = self.size
proc getBit(x:int):int =
  if x > 0 : return 64 - cast[culonglong](x).countLeadingZeroBits()
  return 0
proc pushImpl*[T](self:RadixHeap[T],key:var int) : int =
  self.size += 1
  if not self.saveMin: key = -key
  key = key - self.avalableMin
  let last = self.last
  let bit = getBit(key xor last)
  return bit
proc push*(self:RadixHeap[void],key:int) =
  var key = key
  let bit = self.pushImpl(key)
  self.data[bit].add key
proc push*[T](self:RadixHeap[T],key:int,value:T) =
  var key = key
  let bit = self.pushImpl(key)
  self.data[bit].add((key,value))

proc top*(self:RadixHeap[void]) : int =
  if self.data[0].len == 0:
    var i = 1
    while self.data[i].len == 0 : i += 1
    self.last = self.data[i][0]
    for j in 1..<self.data[i].len:
      if self.data[i][j] < self.last:
        self.last = self.data[i][j]
    for d in self.data[i]:
      self.data[getBit(d xor self.last)].add d
    self.data[i].setLen(0)
  result = self.data[0][^1]
  result += self.avalableMin
  if not self.saveMin: result *= -1

proc top*[T](self:RadixHeap[T]) : KeyValue[T] =
  if self.data[0].len == 0:
    var i = 1
    while self.data[i].len == 0 : i += 1
    self.last = self.data[i][0].key
    for j in 1..<self.data[i].len:
      if self.data[i][j].key < self.last:
        self.last = self.data[i][j].key
    for d in self.data[i]:
      self.data[getBit(d.key xor self.last)].add d
    self.data[i].setLen(0)
  result = self.data[0][^1]
  result.key += self.avalableMin
  if not self.saveMin: result.key *= -1

proc pop*(self:RadixHeap[void]) : int {.discardable.} =
  result = self.top()
  self.size -= 1
  discard self.data[0].pop()

proc pop*[T](self:RadixHeap[T]) : KeyValue[T] {.discardable.} =
  result = self.top()
  self.size -= 1
  discard self.data[0].pop()

when isMainModule:
  import unittest
  import times
  import "../../mathlib/random"
  test "Radix Heap":
    block:
      var R = newAllRangeRadixHeap[void](true)
      for x in @[43,23,43,-44,-11,-130,20]:
        R.push(x)
      for i in 0..<7:
        check:R.pop() == @[-130,-44,-11,20,23,43,43][i]
    block:
      var R = newAllRangeRadixHeap[void](false)
      for x in @[43,23,43,-44,-11,-130,20]:
        R.push(x)
      for i in 0..<7:
        check:R.pop() == @[43,43,23,20,-11,-44,-130][i]
    block:
      var R = newAllRangeRadixHeap[string](false)
      for x in @["aiueo","kaki","sasas","aa"]:
        R.push(x.len,x)
      while R.len > 0:
        echo R.pop()
  if true:
    template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
    stopwatch:
      let n = 1e6.int
      var S = newAllRangeRadixHeap[void](true)
      for _ in 0..n: S.push randomBit(32) - 1 shl 16
      S.pop()
      for _ in 0..n-10: S.pop()
      echo S.pop()
