import sequtils,sugar,strformat,strutils
template times*(n:int,body) = (for _ in 0..<n: body)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

import sequtils,math
type
  SegmentTree[T] = ref object
    data:seq[T]
    n : int
    rawSize:int
    infinity: T
    cmp:proc(x,y:T):T
  SegmentTreeType = enum SaveMin , SaveMax
proc newSegmentTree[T](size:int,segType:SegmentTreeType) : SegmentTree[T] =
  new(result)
  if segType == SaveMin: # 最小値
    proc minimpl[T](x,y:T): T = (if x <= y: x else: y)
    result.infinity = 1e12.T
    result.cmp = minimpl
  elif segType == SaveMax: # 最大値
    proc maximpl[T](x,y:T): T = (if x >= y: x else: y)
    result.infinity = -1e12.T
    result.cmp = maximpl
  else:
    doAssert false
  result.n = size.nextPowerOfTwo()
  result.rawSize = size
  result.data = newSeqWith(result.n * 2,result.infinity)
proc `[]=`[T](self:var SegmentTree[T],i:int,val:T) =
  var i = i + self.n - 1
  self.data[i] = val
  while i > 0:
    i = (i - 1) shr 1
    self.data[i] = self.cmp(self.data[i * 2 + 1],self.data[i * 2 + 2])
proc queryImpl[T](self:SegmentTree[T],a,b,k,l,r:int) : T =
  if r <= a or b <= l : return self.infinity
  if a <= l and r <= b : return self.data[k]
  let vl = self.queryImpl(a,b,k*2+1,l,(l+r) shr 1)
  let vr = self.queryImpl(a,b,k*2+2,(l+r) shr 1,r)
  return self.cmp(vl,vr)
proc `[]`[T](self:SegmentTree[T],slice:Slice[int]): T =
  return self.queryImpl(slice.a,slice.b+1,0,0,self.n)
proc `[]`[T](self:SegmentTree[T],i:int): T = self[i..i]
proc findIndexImpl[T](self:SegmentTree[T],a,b,k,l,r:int,d:int = 0) : int =
  if r <= a or b <= l : return -1
  if a <= l and r <= b : return k
  let vl = self.findIndexImpl(a,b,k*2+1,l,(l+r) shr 1,d+1)
  let vr = self.findIndexImpl(a,b,k*2+2,(l+r) shr 1,r,d+1)
  if vl == -1: return vr
  if vr == -1: return vl
  if self.data[vl] == self.cmp(self.data[vl],self.data[vr]): return vl
  else: return vr
proc findIndex[T](self:SegmentTree[T],slice:Slice[int]): int =
  var index = self.findIndexImpl(slice.a,slice.b+1,0,0,self.n)
  while index < self.n - 1:
    let l = index * 2 + 1
    if self.data[l] == self.data[index] : index = l
    else: index = l + 1
  return index - (self.n - 1)

proc `$`[T](self:SegmentTree[T]): string =
  var arrs : seq[seq[int]] = @[]
  var l = 0
  var r = 1
  while r <= self.data.len:
    arrs.add self.data[l..<r]
    l = l * 2 + 1
    r = r * 2 + 1
  return $arrs


let n = scan()
let q = scan()
var S = newSegmentTree[int](n,SaveMin)
for i in 0..<n: S[i] = scan()
q.times:
  let (x,l,r) = (scan(),scan()-1,scan()-1)
  if x == 1: (S[l],S[r]) = (S[r],S[l])
  else: echo S.findIndex(l..r) + 1
