import sequtils,algorithm,math,strutils
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
GC_disableMarkAndSweep()
template useMatrix =
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
          when declared(MOD):
            n = (n + (a[k,y] * b[x,k]) mod MOD) mod MOD
          else:
            n += a[k,y] * b[x,k]
        result[x,y] = n

  proc `*`[T](a:Matrix,b:seq[T]):seq[T] =
    assert a.w == b.len
    result = newSeq[T](b.len)
    for x in 0..<a.h:
      var n : T
      for k in 0..<a.w:
        when declared(MOD):
          n = (n + (a[k,x] * b[k]) mod MOD) mod MOD
        else:
          n += a[k,x] * b[k]
      result[x] = n

  proc `^`[T](m:Matrix[T],n:int) : Matrix[T] =
    assert m.w == m.h
    if n <= 0 : return identityMatrix[T](m.w)
    if n == 1 : return m
    let m2 = m^(n div 2)
    if n mod 2 == 0 : return m2 * m2
    return m2 * m2 * m

  # CSR 実装
  # let M = newMatrix(@[@[1,2,3,0],@[0,0,0,1],@[2,0,0,2],@[0,0,0,1]])
  type SparseMatrix[T] = ref object
    w,h:int
    data: seq[T]
    row: seq[int]
    col: seq[int]
  proc newSparseMatrix[T](m:Matrix[T]):SparseMatrix[T] =
    new(result)
    result.w = m.w
    result.h = m.h
    for y in 0..<m.h:
      result.col &= result.data.len
      for x in 0..<m.w:
        if m[x,y] <= T(0) : continue
        result.data &= m[x,y]
        result.row &= x
    result.col &= result.data.len
  proc newSparseMatrix[T](m:seq[seq[T]]):SparseMatrix[T] =
    new(result)
    result.w = m.len()
    result.h = m[0].len
    for y in 0..<result.h:
      result.col &= result.data.len
      for x in 0..<result.w:
        if m[x][y] <= T(0) : continue
        result.data &= m[x][y]
        result.row &= x
    result.col &= result.data.len
  proc newSparseMatrix[T](w,h:int):SparseMatrix[T] =
    new(result)
    result.w = w
    result.h = h
    result.data = @[]
    result.col = @[]
    result.row = @[]
  proc `*`[T](m:SparseMatrix[T],v:seq[T]):seq[T] =
    result = newSeq[T](m.h)
    for y in 0..<m.h:
      var n : T
      for x in m.col[y]..<m.col[y+1]:
        n += m.data[x] * v[m.row[x]]
      result[y] = n
  proc `*`[T](m1,m2:SparseMatrix[T]) : SparseMatrix[T] =
    var R = newSeqWith(m2.w,newSeq[T](m2.h))
    for y in 0..<m2.h:
      for x in m2.col[y]..<m2.col[y+1]:
        R[m2.row[x]][y] = m2.data[x]
    for x in 0..<m2.w: R[x] = m1 * R[x]
    return newSparseMatrix(R)
  proc `^`[T](m:SparseMatrix[T],n:int) : SparseMatrix[T] =
    assert m.w == m.h
    if n <= 0 : return identityMatrix[T](m.w).newSparseMatrix()
    if n == 1 : return m
    let m2 = m^(n div 2)
    if n mod 2 == 0 : return m2 * m2
    return m2 * m2 * m
  proc `$`[T](m:SparseMatrix[T]):string =
    result = ""
    for y in 0..<m.h:
      result &= "["
      for x in m.col[y]..<m.col[y+1]:
        result &= $m.data[x] & "(" & $m.row[x] & ") "
      result &= "]\n"
    result &= "\n"

useMatrix()

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let h = scan() - 2
let w = scan() - 2
let t = scan()
let (sy,sx) = (scan()-1,scan()-1)
let (gy,gx) = (scan()-1,scan()-1)
if (sx + sy + gx + gy) mod 2 != t mod 2:
  quit "0.0",0
var B = newSeqWith(w,newSeq[char](h))
(w+3).times:discard getchar_unlocked()
for y in 0..<h:
  discard getchar_unlocked()
  for x in 0..<w:
    B[x][y] = getchar_unlocked()
  discard getchar_unlocked()
  discard getchar_unlocked()
var M = newMatrix[float](w*h,w*h)
var I = newSeq[float](w*h)
proc encode(x,y:int):int = x+w*y
I[encode(sx,sy)] = 1.0
for y in 0..<h:
  for x in 0..<w:
    if B[x][y] == '#' : continue
    var cnt = 0
    const dxdy4 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0)]
    for d in dxdy4:
      let nx = x + d.x
      let ny = y + d.y
      if nx < 0 or ny < 0 or nx >= w or ny >= h : continue
      if B[nx][ny] == '#' : continue
      cnt += 1
    if cnt == 0:
      M[encode(x,y),encode(x,y)] = 1.0
      continue
    for d in dxdy4:
      let nx = x + d.x
      let ny = y + d.y
      if nx < 0 or ny < 0 or nx >= w or ny >= h : continue
      if B[nx][ny] == '#' : continue
      M[encode(x,y),encode(nx,ny)] = 1.0 / cnt.float

let SM = newSparseMatrix(M)
echo ((M^t)*I)[encode(gx,gy)]