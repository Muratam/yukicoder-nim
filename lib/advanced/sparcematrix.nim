# 疎行列(CSR) ####################################################
import sequtils
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
    result.col .add result.data.len
    for x in 0..<m.w:
      if m[x,y] <= T(0) : continue
      result.data .add m[x,y]
      result.row .add x
  result.col .add result.data.len
proc newSparseMatrix[T](m:seq[seq[T]]):SparseMatrix[T] =
  new(result)
  result.w = m.len()
  result.h = m[0].len
  for y in 0..<result.h:
    result.col .add result.data.len
    for x in 0..<result.w:
      if m[x][y] <= T(0) : continue
      result.data .add m[x][y]
      result.row .add x
  result.col .add result.data.len
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
    result .add "["
    for x in m.col[y]..<m.col[y+1]:
      result .add $m.data[x] & "(" & $m.row[x] & ") "
    result .add "]\n"
  result .add "\n"
