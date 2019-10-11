import algorithm
# f(x) in [s,t] において f(x)=true となる境界を求める
# s,t どちらも f()=false の場合は未定義動作
proc binarySearch[T](slice:Slice[T],f:proc(x:T):bool):T =
  let s = slice.a
  let t = slice.b
  var ng,ok : T
  let ft = f(t)
  let fs = f(s)
  if ft and fs : return s
  if ft: # t が必ず満たす時
    ng = s - 1
    ok = t + 1
  elif fs: # s が必ず満たす時
    ok = s - 1
    ng = t + 1
  else: assert false
  var fok = ok
  when T is int:
    template COND():bool=abs(ng - ok) > 1
    template MID():T=(ng + ok) div 2 # 値は負になりうるので
  elif T is float:
    template COND():bool=abs(ng - ok) > 1e-12
    template MID():T=ng * 0.5 + ok * 0.5
  else: assert false
  while COND():
    let mid = MID()
    if f(mid): ok = mid
    else: ng = mid
  assert ok != fok # 全てで false
  return ok

# f(x) in [s,t] において f(x)が最大or最小となる時の値を求める
# 非凸な単調関数でも適応可能(その場合は端点)
type SearchType = enum SearchMin,SearchMax
proc termarySearch[T,S](slice:Slice[T],f:proc(x:T):S,searchType:static[SearchType]):T =
  var a = slice.a
  var b = slice.b
  when searchType == SearchMin:
    template CMP(x,y):bool = x < y
  elif searchType == SearchMax:
    template CMP(x,y):bool = x > y
  when T is int:
    template COND():bool=b - a <= 1
    template MID(x,y):T=(x+y) div 2
  elif T is float:
    template COND():bool=abs(b - a) < 1e-12
    template MID(x,y):T=x* 0.5 + y* 0.5
  else: assert false
  while true:
    let m = MID(a,b)
    let fa = f(a)
    let fm = f(m)
    let fb = f(b)
    let na = if CMP(fm,fa): MID(a,m) else:a
    let nb = if CMP(fm,fb): MID(m,b) else:b
    if na == a and nb == b:
      if CMP(fm,fa) and CMP(fm,fb) : return m
      if CMP(fa,fm) and CMP(fa,fb) : return a
      return b
    a = na
    b = nb
    if COND():
      when T is int: return if CMP(f(a),f(b)) : a else: b
      elif T is float: return m

# Lower Bound を使いこなせると(静的なら)動的木は不要wwww
#     > <=           >=  <
#  ... [lowerBound ... ][upperBound ...
#  ... [x:         ... ][succ(x):   ...
import algorithm
when not defined(upperBound) : # Nim0.13.0には無いため
  proc upperBound[T](a: openArray[T], key: T): int =
    result = a.low
    var count = a.high - a.low + 1
    var step, pos: int
    while count != 0:
      step = count shr 1
      pos = result + step
      if cmp(a[pos], key) <= 0:
        result = pos + 1
        count -= step + 1
      else:
        count = step
# 指定キー{以上,超過}のうちの最小のindex(満たすものがなければarr.lenになる)
proc greater[T](arr:seq[T],key:T,including:bool): int =
  if including : arr.lowerBound(key)
  else: arr.upperBound(key)
# 指定キー{未満,以下}のうちの最大のindex(無い時は-1)
proc less[T](arr:seq[T],key:T,including:bool): int =
  if including : arr.upperBound(key) - 1
  else: arr.lowerBound(key) - 1
# [at.key <= arr <= at.b ] の範囲が帰るのでそのままiterateしてよい.
# 中に要素が無ければ b < key と逆転した結果が帰るので分かる.
proc at[T](arr:seq[T],slice:Slice[T]): Slice[int] =
  arr.greater(slice.a,true)..arr.less(slice.b,true)
# 要素数
proc count[T](arr:seq[T],key:T): int =
  arr.upperBound(key) - arr.lowerBound(key)


when isMainModule:
  import unittest
  import sequtils
  test "binarysearch":
    check:binarySearch(7..20,proc(x:int):bool = x * x > 48) == 7
    check:binarySearch(7..9,proc(x:int):bool = x * x > 49) == 8
    check:binarySearch(7..8,proc(x:int):bool = x * x > 49) == 8
    check:binarySearch(7..7,proc(x:int):bool = x * x >= 49) == 7
    check:binarySearch(2..30,proc(x:int):bool = x * x > 50) == 8
    check:binarySearch(3..20,proc(x:int):bool = x * x >= 63) == 8
    check:binarySearch(4..25,proc(x:int):bool = x * x >= 64) == 8
    check:binarySearch(5..30,proc(x:int):bool = x * x >= 65) == 9
    check:binarySearch(0..20,proc(x:int):bool = x * x < 48) == 6
    check:binarySearch(1..25,proc(x:int):bool = x * x < 49) == 6
    check:binarySearch(2..30,proc(x:int):bool = x * x < 50) == 7
    check:binarySearch(3..20,proc(x:int):bool = x * x <= 63) == 7
    check:binarySearch(4..25,proc(x:int):bool = x * x <= 64) == 8
    check:binarySearch(5..30,proc(x:int):bool = x * x <= 65) == 8
    check:binarySearch(5..8,proc(x:int):bool = x * x <= 65) == 5
    let A = @[2,3,5,7,9,11,13,4134,4325542,54353543]
    check:A[binarySearch(0..<A.len,proc(x:int):bool = A[x] > 13)] == 4134
    check:A[binarySearch(0..<A.len,proc(x:int):bool = A[x] < 13)] == 11
    check:A.lowerBound(3) == binarySearch(0..<A.len,proc(x:int):bool=A[x]>=3)
    check:A.lowerBound(4) == binarySearch(0..<A.len,proc(x:int):bool=A[x]>=4)
    check:A.lowerBound(5) == binarySearch(0..<A.len,proc(x:int):bool=A[x]>=5)
    check:abs(binarySearch(0.0..10.0,proc(x:float):bool = x * x < 3.14159265358979) - 1.772453850904867)<1e-10
    check:abs(binarySearch(-10.0..0.0,proc(x:float):bool = x * x > 3.14159265358979) + 1.772453850905548)<1e-10
  test "termarysearch":
    check:termarySearch(-10..100,proc(x:int):int= x * x + 20,SearchMin) == 0
    check:termarySearch(5..10,proc(x:int):int= x * x + 20,SearchMin) == 5
    check:termarySearch(-10.. -5,proc(x:int):int= x * x + 20,SearchMin) == -5
    check:termarySearch(-1..2,proc(x:int):int= x * x + 20,SearchMin) == 0
    check:termarySearch(-1..3,proc(x:int):int= x * x + 20,SearchMin) == 0
    check:termarySearch(0..0,proc(x:int):int= x * x + 20,SearchMin) == 0
    check:termarySearch(-1..0,proc(x:int):int= x * x + 20,SearchMin) == 0
    check:termarySearch(0..1,proc(x:int):int= x * x + 20,SearchMin) == 0
    check:abs(termarySearch(-0.5..1.0,proc(x:float):float= x * x + 20,SearchMin)) < 1e-5
    check:abs(termarySearch(-0.5..1.0,proc(x:float):float= -x * x + 20,SearchMax)) < 1e-5
    check:abs(termarySearch(-1.5..1.0,proc(x:float):float= x * x + 20,SearchMax)+1.5) < 1e-8
    check:abs(termarySearch(-1.0..1.5,proc(x:float):float= x * x + 20,SearchMax)-1.5) < 1e-8
    check:abs(termarySearch(-0.5..1.0,proc(x:float):float= -x * x + 20,SearchMin)-1.0) < 1e-8
    check:abs(termarySearch(-1.5..0.5,proc(x:float):float= -x * x + 20,SearchMin)+1.5) < 1e-8
    check:termarySearch(-3..8,proc(x:int):int= x * x + 20,SearchMax) == 8
    check:termarySearch(-8..3,proc(x:int):int= x * x + 20,SearchMax) == -8
    # 最大値が複数ある時,どれになるかは不明であることに注意
    let A = @[1,2,3,4,5,5,5,5,2,0]
    check:termarySearch(0..<A.len,proc(x:int):int= A[x],SearchMax) notin [4,7]
  test "<= > < >= at":
    check: @[1,2,3,4,5,7,8,10].mapIt(@[2,4,6,8].greater(it,true)) == @[0, 0, 1, 1, 2, 3, 3, 4]
    check: @[1,2,3,4,5,7,8,10].mapIt(@[2,4,6,8].greater(it,false)) == @[0, 1, 1, 2, 2, 3, 4, 4]
    check: @[1,2,3,4,5,7,8,10].mapIt(@[2,4,6,8].less(it,false)) == @[-1, -1, 0, 0, 1, 2, 2, 3]
    check: @[1,2,3,4,5,7,8,10].mapIt(@[2,4,6,8].less(it,true)) == @[-1, 0, 0, 1, 1, 2, 3, 3]
    check: @[1,2,3,4,5,10].at(2..4)  == 1..3
    check: @[1,2,3,4,5,10].at(5..11) == 4..5
    check: @[1,2,3,4,5,10].at(0..11) == 0..5
    check: @[1,2,3,4,5,10].at(6..6)  == 5..4
    check: @[1,2,3,3,3,4,4].count(1) == 1
    check: @[1,2,3,3,3,4,4].count(3) == 3
    check: @[1,2,3,3,3,4,4].count(4) == 2
    check: @[1,2,3,3,3,4,4,6].count(5) == 0
    check: @[1,2,3,3,3,4,4,6].count(7) == 0
    check: @[1,2,3,3,3,4,4,6].count(0) == 0
