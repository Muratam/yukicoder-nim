import sequtils
# import algorithm,math,tables
# import sets,intsets,queues,heapqueue,bitops,strutils
# import strutils,strformat,sugar,macros,times
# template stopwatch(body) = (let t1 = cpuTime();body;echo "TIME:",(cpuTime() - t1) * 1000,"ms")
# template `^`(n:int) : int = (1 shl n)
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

type Matrix[T] = ref object
  w,h:int
  data: seq[T]
proc `[]`[T](m:Matrix[T],x,y:int):T = m.data[x + y * m.w]
proc `[]=`[T](m:var Matrix[T],x,y:int,val:T) = m.data[x + y * m.w] = val
proc newMatrix[T](w,h:int):Matrix[T] =
  new(result)
  result.w = w
  result.h = h
  result.data = newSeq[T](w * h)
proc identityMatrix[T](n:int):Matrix[T] =
  result = newMatrix[T](n,n)
  for i in 0..<n: result[i,i] = 1
proc newMatrix[T](arr:seq[seq[T]]):Matrix[T] =
  new(result)
  result.w = arr[0].len
  result.h = arr.len
  result.data = newSeq[T](result.w * result.h)
  for x in 0..<result.w:
    for y in 0..<result.h:
      result[x,y] = arr[y][x]

proc `$`[T](m:Matrix[T]) : string =
  result = ""
  for y in 0..<m.h:
    result &= "["
    for x in 0..<m.w:
      result &= $m[x,y]
      if x != m.w - 1 : result &= ","
    result &= "]"
    if y != m.h - 1 : result &= "\n"
  result &= "\n"

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
  let m2 = m ^ (n div 2)
  if n mod 2 == 0 : return m2 * m2
  return m2 * m2 * m



proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
if n == 0 : quit "1",0
let M = newMatrix(@[@[1,4],@[1,1]])
let MN = M^(n-1)
var re1 = MN[0,0] + MN[1,0]
var sq3 = MN[0,1] + MN[1,1]
echo re1
echo sq3