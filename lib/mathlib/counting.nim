import modint

# nCk
proc combination(n,k:int) : ModInt =
  result = 1.toModInt()
  let y = k.min(n - k)
  var fact = 1.toModInt()
  for i in 2..y: fact = fact * i
  for i in 1..y: result = result * (n+1-i)
  result = result / fact

# 転倒数
# i < j かつ Ai > Aj な組
# verify : https://chokudai_s001.contest.atcoder.jp/tasks/chokudai_S001_j
import "../datastructure/segmenttree/bit"
proc inversionNumber[T](arr:seq[T]) : int =
  if arr.len <= 1 : return 0
  var bit = newAddBinaryIndexedTree[int](arr.len)
  for i,a in arr:
    result += i - bit.until(a)
    bit.update(a,1)

# カタラン数
# ()の正しい並び替えの組み合わせ
proc catalanNumber(n:int) : ModInt = combination(n*2,n) / (n + 1).toModInt()

# sternBrocot木
# http://mathworld.wolfram.com/Stern-BrocotTree.html
# 小さい順に既約分数を列挙する. 1/maxNum から maxNum/1 まで
proc sternBrocotTree(maxNum:int): seq[tuple[u,d:int]] =
  var tree = newSeq[tuple[u,d:int]]()
  proc impl(au,ad,bu,bd:int) =
    let mu = au + bu
    let md = ad + bd
    if mu > maxNum or md > maxNum : return
    impl(au,ad,mu,md)
    tree.add((mu,md))
    impl(mu,md,bu,bd)
  impl(0,1,1,0)
  return tree

# 第2種スターリング数
# 区別できる n 個のボールを区別できない k 個の箱に分割する方法の数
# https://ei1333.github.io/luzhiled/snippets/math/stirling-number-second.html
proc stirlingNumber2(n,k:int):ModInt =
  for i in 0..k:
    result = result + (if (k-i) mod 2 == 0: 1 else: -1) * k.combination(i) * (i.toModInt()^n)
  var fact = 1.toModInt()
  for i in 2..k: fact = fact * i
  return result / fact

# ベル数 B(n,k)
# 区別できる n 個のボールを区別できない k 個以下の箱に分割する方法の数を与える。
# B(n,n) は n 個のボールを任意個のグループに分割する方法の数
# https://ei1333.github.io/luzhiled/snippets/math/bell-number.html

when isMainModule:
  import unittest,sequtils
  test "modint":
    check: 100.combination(50) == 538992043.toModInt()
    for i,c in @[1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862, 16796, 58786, 208012, 742900, 2674440, 9694845]:
      check: i.catalanNumber() == c.toModInt()
    check: sternBrocotTree(3) == @[(1,3),(1,2),(2,3),(1,1),(3,2),(2,1),(3,1)]
  test "inversion number":
    check: @[3,1,5,4,2].inversionNumber() == 5
