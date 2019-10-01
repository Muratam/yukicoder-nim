# 行列 #################################################
type Matrix*[T] = ref object
  w*,h*:int
  data*: seq[T]
proc `[]`*[T](m:Matrix[T],x,y:int):T = m.data[x + y * m.w]
proc `[]`*[T](m:var Matrix[T],x,y:int):var T = m.data[x + y * m.w]
proc `[]=`*[T](m:var Matrix[T],x,y:int,val:T) = m.data[x + y * m.w] = val
proc newMatrix*[T](w,h:int):Matrix[T] =
  new(result)
  result.w = w
  result.h = h
  result.data = newSeq[T](w * h)
proc identityMatrix*[T](n:int):Matrix[T] =
  result = newMatrix[T](n,n)
  for i in 0..<n: result[i,i] = 1
proc newMatrix*[T](arr:seq[seq[T]]):Matrix[T] =
  new(result)
  result.w = arr[0].len
  result.h = arr.len
  result.data = newSeq[T](result.w * result.h)
  for x in 0..<result.w:
    for y in 0..<result.h:
      result[x,y] = arr[y][x]
proc `*`*[T](a,b:Matrix[T]): Matrix[T] =
  assert a.w == b.h
  result = newMatrix[T](a.h,b.w)
  for y in 0..<a.h:
    for x in 0..<b.w:
      var n : T
      for k in 0..<a.w:
        n += a[k,y] * b[x,k]
      result[x,y] = n
proc `^`*[T](m:Matrix[T],n:int) : Matrix[T] =
  assert m.w == m.h
  if n <= 0 : return identityMatrix[T](m.w)
  if n == 1 : return m
  let m2 = m^(n div 2)
  if n mod 2 == 0 : return m2 * m2
  return m2 * m2 * m
proc `$`*[T](m:Matrix[T]) : string =
  result = ""
  for y in 0..<m.h:
    result .add "["
    for x in 0..<m.w:
      result .add $m[x,y]
      if x != m.w - 1 : result .add ","
    result .add "]"
    if y != m.h - 1 : result .add "\n"
  result .add "\n"

proc `*`*[T](a:Matrix,b:seq[T]):seq[T] =
  assert a.w == b.len
  result = newSeq[T](b.len)
  for x in 0..<a.h:
    var n : T
    for k in 0..<a.w:
      n += a[k,x] * b[k]
    result[x] = n
proc `+`*[T](a,b:Matrix[T]): Matrix[T] =
  assert a.w == b.w and a.h == b.h
  result = newMatrix[T](a.w,a.h)
  for y in 0..<a.h:
    for x in 0..<b.w:
      result[x,y] = a[x,y] + b[x,y]
proc transpose*[T](a:Matrix[T]): Matrix[T] =
  result = newMatrix[T](a.h,a.w)
  for y in 0..<a.h:
    for x in 0..<a.w:
      result[x,y] = a[y,x]
template mapIt*[T](M: Matrix[T],op): untyped =
  type outType = type((var it{.inject.}: T;op))
  var i = 0
  var result = newMatrix[outType](M.w,M.h)
  for y in 0..<M.h:
    for x in 0..<M.w:
      let it {.inject.} = M[x,y]
      result[x,y] = op
  result



when isMainModule:
  import unittest
  import sequtils
  proc `==`(a,b:Matrix[int]): bool =
    for y in 0..<a.h:
      for x in 0..<a.w:
        if a[x,y] != b[x,y] : return false
    return true
  test "matrix":
    let I = identityMatrix[int](10)
    check: I == I * I + newMatrix[int](10,10)
    check: I.transpose == I * I
    check: I.mapIt(it * it) == I * I
    check: I * toSeq(1..10) == toSeq(1..10)
    check: I^100 == I^1000
