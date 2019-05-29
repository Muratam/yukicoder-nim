# セグツリ 区間[s,t)の最小(最大)値 / 更新 O(log(N))
proc minimpl[T](x,y:T): T = (if x <= y: x else: y)
proc maximpl[T](x,y:T): T = (if x >= y: x else: y)
type SegmentTree[T] = ref object
  data:seq[T] # import math
  n : int
  rawSize:int
  infinity: T
  cmp:proc(x,y:T):T
proc newSegmentTree[T](
    size:int,
    infinity:T = T(1e10),
    cmp: proc (x,y:T):T = minimpl[T]) : SegmentTree[T] =
  new(result)
  result.infinity = infinity
  result.cmp = cmp
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
proc `$`[T](self:SegmentTree[T]): string =
  var arrs : seq[seq[int]] = @[]
  var l = 0
  var r = 1
  while r <= self.data.len:
    arrs &= self.data[l..<r]
    l = l * 2 + 1
    r = r * 2 + 1
  return $arrs
#
