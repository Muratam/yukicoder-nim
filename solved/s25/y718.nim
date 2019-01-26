import sequtils,math

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

const MOD = 1000000007

template useMatrix =
  type Matrix = ref object
    w,h:int
    data: seq[int]
  proc `[]`(m:Matrix,x,y:int):int = m.data[x + y * m.w]
  proc `[]=`(m:var Matrix,x,y,val:int) = m.data[x + y * m.w] = val
  proc newMatrix(w,h:int):Matrix =
    new(result)
    result.w = w
    result.h = h
    result.data = newSeq[int](w * h)
  proc identityMatrix(n:int):Matrix =
    result = newMatrix(n,n)
    for i in 0..<n: result[i,i] = 1
  proc newMatrix(arr:seq[seq[int]]):Matrix =
    new(result)
    result.w = arr[0].len
    result.h = arr.len
    result.data = newSeqUninitialized[int](result.w * result.h)
    for x in 0..<result.w:
      for y in 0..<result.h:
        result[x,y] = arr[y][x]

  proc `$`(m:Matrix) : string =
    result = ""
    for y in 0..<m.h:
      result &= "["
      for x in 0..<m.w:
        result &= $m[x,y]
        if x != m.w - 1 : result &= ","
      result &= "]"
      if y != m.h - 1 : result &= "\n"
    result &= ""

  proc `*`(a,b:Matrix): Matrix =
    assert a.w == b.h
    result = newMatrix(a.h,b.w)
    for y in 0..<a.h:
      for x in 0..<b.w:
        var n = 0
        for k in 0..<a.w:
          when declared(MOD):
            n = (n + (a[k,y] * b[x,k]) mod MOD) mod MOD
          else:
            n += a[k,y] * b[x,k]
        result[y,x] = n

  proc `*`(a:Matrix,b:seq[int]):seq[int] =
    assert a.w == b.len
    result = newSeq[int](b.len)
    for x in 0..<a.h:
      var n = 0
      for k in 0..<a.w:
        when declared(MOD):
          n = (n + (a[k,x] * b[k]) mod MOD) mod MOD
        else:
          n += a[k,x] * b[k]
      result[x] = n

  proc `^`(m:Matrix,n:int) : Matrix =
    assert m.w == m.h
    if n <= 0 : return identityMatrix(m.w)
    if n == 1 : return m
    let m2 = m^(n div 2)
    if n mod 2 == 0 : return m2 * m2
    return m2 * m2 * m
useMatrix()

proc calcFib(n:int):int = (newMatrix(@[@[1,1],@[1,0]])^(n-1)*(@[1,0]))[0]
#F(n) = f(n+1) * f(n)
let n = scan()
echo (calcFib(n) * calcFib(n+1)) mod MOD

