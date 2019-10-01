# 連続がいくつ続くか
proc countContinuity[T](arr:seq[T]) : seq[tuple[key:T,cnt:int]] =
  if arr.len == 0 : return @[]
  result = @[]
  var pre = arr[0]
  var cnt = 0
  for a in arr:
    if a == pre: cnt += 1
    else:
      result .add((pre,cnt))
      cnt = 1
      pre = a
  result.add((pre,cnt))

# Nim 0.13 の toCountTable はバグがあるので注意
import math,tables,algorithm,sequtils
proc toCountTable*[A](keys: openArray[A]): CountTable[A] =
  result = initCountTable[A](nextPowerOfTwo(keys.len * 3 div 2 + 4))
  for key in items(keys):
    result[key] = 1 + (if key in result : result[key] else: 0)

# string -> seq[char]
import sequtils
proc toArray(s:string) :seq[char]= s.mapIt(it)
import macros
macro toTuple*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
import strutils
proc `*`(str:string,t:int):string = str.repeat(t)

# 数の配列のソート用
proc cmp(x,y:seq[int]):int =
  for i in 0..<min(x.len,y.len):
    if x[i] != y[i] : return x[i] - y[i]
  return x.len - y.len

proc toAlphabet(a:int) : string = # 26進数(A..Z,AA..ZZ,...)
  proc impl(a:int) : seq[char] =
    let c = a mod 26
    let s = ('A'.ord + c).chr
    if a < 26: return @[s]
    result = impl(a div 26 - 1)
    result .add s
  return cast[string](impl(a))


when isMainModule:
  import unittest
  test "Nim 0.13 Compatibility":
    let arr = "iikannji".toArray()
    check: @[1,3,7,-1,10,5,3,10,-1].find(3) == 1
    check: "aaabii".mapIt(it).countContinuity() == @[('a',3),('b',1),('i',2)]

    check: arr == @['i', 'i', 'k', 'a', 'n', 'n', 'j', 'i']
    check: arr.toCountSeq() == @[('a', 1), ('i', 3), ('j', 1), ('k', 1), ('n', 2)]
