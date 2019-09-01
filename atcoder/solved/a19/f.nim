import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord


# 行列 #################################################
type Matrix[T] = ref object
  w,h:int
  data: seq[T]
proc `[]`[T](m:Matrix[T],x,y:int):T = m.data[x + y * m.w]
proc `[]`[T](m:var Matrix[T],x,y:int):var T = m.data[x + y * m.w]
proc `[]=`[T](m:var Matrix[T],x,y:int,val:T) = m.data[x + y * m.w] = val
proc newMatrix[T](w,h:int):Matrix[T] =
  new(result)
  result.w = w
  result.h = h
  result.data = newSeq[T](w * h)
proc identityMatrix[T](n:int):Matrix[T] =
  result = newMatrix[T](n,n)
  for i in 0..<n: result[i,i] = 1.toModInt()
proc newMatrix[T](arr:seq[seq[T]]):Matrix[T] =
  new(result)
  result.w = arr[0].len
  result.h = arr.len
  result.data = newSeq[T](result.w * result.h)
  for x in 0..<result.w:
    for y in 0..<result.h:
      result[x,y] = arr[y][x]
proc `*`[T](a,b:Matrix[T]): Matrix[T] =
  assert a.w == b.h
  result = newMatrix[T](a.h,b.w)
  for y in 0..<a.h:
    for x in 0..<b.w:
      var n : T
      for k in 0..<a.w:
        n += a[k,y] * b[x,k]
      result[x,y] = n
proc `^`[T](m:Matrix[T],n:int) : Matrix[T] =
  assert m.w == m.h
  if n <= 0 : return identityMatrix[T](m.w)
  if n == 1 : return m
  let m2 = m^(n div 2)
  if n mod 2 == 0 : return m2 * m2
  return m2 * m2 * m
proc `$`[T](m:Matrix[T]) : string =
  result = ""
  for y in 0..<m.h:
    result .add "["
    for x in 0..<m.w:
      result .add $m[x,y]
      if x != m.w - 1 : result .add ","
    result .add "]"
    if y != m.h - 1 : result .add "\n"
  result .add "\n"

proc `*`[T](a:Matrix,b:seq[T]):seq[T] =
  assert a.w == b.len
  result = newSeq[T](b.len)
  for x in 0..<a.h:
    var n : T
    for k in 0..<a.w:
      n = n + a[k,x] * b[k]
    result[x] = n
proc `+`[T](a,b:Matrix[T]): Matrix[T] =
  assert a.w == b.w and a.h == b.h
  result = newMatrix[T](a.w,a.h)
  for y in 0..<a.h:
    for x in 0..<b.w:
      result[x,y] = a[x,y] + b[x,y]
proc transpose[T](a:Matrix[T]): Matrix[T] =
  result = newMatrix[T](a.h,a.w)
  for y in 0..<a.h:
    for x in 0..<a.w:
      result[x,y] = a[y,x]
template mapIt[T](M: Matrix[T],op): untyped =
  type outType = type((var it{.inject.}: T;op))
  var i = 0
  var result = newMatrix[outType](M.w,M.h)
  for y in 0..<M.h:
    for x in 0..<M.w:
      let it {.inject.} = M[x,y]
      result[x,y] = op
  result

type ModInt = object
  v:int # 0~MODに収まる
var MOD = 0
proc toModInt*(a:int) : ModInt =
  if a < -MOD : result.v = ((a mod MOD) + MOD) mod MOD
  elif a < 0 : result.v = a + MOD
  elif a >= MOD: result.v = a mod MOD
  else: result.v = a
proc `+`*(a,b:ModInt) : ModInt =
  result.v = a.v + b.v
  if result.v >= MOD : result.v = result.v mod MOD
proc `*`*(a,b:ModInt) : ModInt =
  result.v = a.v * b.v
  if result.v >= MOD : result.v = result.v mod MOD
proc `^`*(a:ModInt,b:int) : ModInt =
  if a.v == 0 : return 0.toModInt()
  if b == 0 : return 1.toModInt()
  if b == 1 : return a
  if b > MOD: return a^(b mod (MOD-1)) # フェルマーの小定理
  let pow = a^(b div 2)
  if b mod 2 == 0 : return pow * pow
  return pow * pow * a
proc `+`*(a:int,b:ModInt) : ModInt = a.toModInt() + b
proc `+`*(a:ModInt,b:int) : ModInt = a + b.toModInt()
proc `-`*(a:ModInt,b:int) : ModInt = a + (-b)
proc `-`*(a,b:ModInt) : ModInt = a + (-b.v)
proc `-`*(a:int,b:ModInt) : ModInt = a.toModInt() + (-b.v)
proc `*`*(a:int,b:ModInt) : ModInt = a.toModInt() * b
proc `*`*(a:ModInt,b:int) : ModInt = a * b.toModInt()
proc `/`*(a,b:ModInt) : ModInt = a * b^(MOD-2)
proc `$`*(a:ModInt) : string = $a.v


proc inv(M:var Matrix[ModInt]): Matrix[ModInt] =
  let n = M.w
  result = identityMatrix[ModInt](n)
  for i in 0..<n:
    var buf = 1.toModInt() / M[i,i]
    for j in 0..<n:
      M[i,j] = M[i,j] *  buf
      result[i,j] = result[i,j] *  buf
    for j in 0..<n:
      if i == j : continue
      var buf = M[j,i]
      for k in 0..<n:
        M[j,k] = M[j,k] - M[i,k] * buf
        result[j,k] = result[j,k] - result[i,k] * buf




let p = scan()
MOD = p
proc power(x,n:int): int =
  if n <= 1: return if n == 1: x else: 1
  let pow_2 = power(x,n div 2)
  return (pow_2 * pow_2 * (if n mod 2 == 1: x else: 1)) mod p



let A = newSeqWith(p,scan().toModInt())
var M = newMatrix[ModInt](p,p)
for x in 0..<p:
  for y in 0..<p:
    M[y,x] = x.toModInt()^y
var ans : seq[string] = @[]
var B = M.inv() * A
for i in 0..<p:
  ans.add($B[i])

echo ans.join(" ")
