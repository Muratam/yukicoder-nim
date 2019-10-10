# 全ての組み合わせを全探索
import algorithm
template permutationIter[T](arr:var seq[T],body) =
  arr.sort(cmp[T])
  while true:
    body
    if not arr.nextPermutation() : break

# 2つずつのペアを取った際に重複しないように組み合わせを回す。
# => 任意のペアの組み合わせを全探索できる。
import algorithm
template pairPermutationIter[T](arr:var seq[T],body) =
  arr.sort(cmp[T])
  while true:
    body
    arr.reverse(arr.len div 2,arr.len - 1)
    if not arr.nextPermutation() : break

# [0,w), [0,h) までを 和が等しい順に回す
iterator chair(w,h:int): tuple[x,y:int] =
  for n in 0..w + h:
    for x in 0.max(n-h+1)..n.min(w-1):
      yield (x,n-x)

# bitDPの iteration は bitset.nim にあるよ


when isMainModule:
  import unittest
  test "iteration":
    block:
      var i = 0
      for x,y in chair(2,3):
        check: x == @[0,0,1,0,1,1][i]
        check: y == @[0,1,0,2,1,2][i]
        i += 1
    block:
      var arr = @[3,1,5]
      var i = 0
      arr.permutationIter:
        check: arr == @[@[1,3,5],@[1,5,3],@[3,1,5],@[3,5,1],@[5,1,3],@[5,3,1]][i]
        i += 1
    block:
      var arr = @[3,1,5]
      var i = 0
      arr.pairPermutationIter:
        check: arr == @[@[1,3,5],@[3,1,5],@[5,1,3]][i]
        i += 1
