import sequtils,math
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

template useSegmentTree() = # 区間[s,t)の最小(最大)値 / 更新 O(log(N))
  proc minimpl[T](x,y:T): T = (if x <= y: x else: y)
  proc maximpl[T](x,y:T): T = (if x >= y: x else: y)
  type SegmentTree[T] = ref object
    data:seq[T] # import math
    n : int
    rawSize:int
    infinity: T
    cmp:proc(x,y:T):T
  proc initSegmentTree[T](
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
  proc `[]`[T](self:SegmentTree[T],slice:Slice[int]): T =
    proc impl(a,b,k,l,r:int):T =
      if r <= a or b <= l : return self.infinity
      if a <= l and r <= b : return self.data[k]
      let vl = impl(a,b,k*2+1,l,(l+r) shr 1)
      let vr = impl(a,b,k*2+2,(l+r) shr 1,r)
      return self.cmp(vl,vr)
    return impl(slice.a,slice.b+1,0,0,self.n)

  proc `$`[T](self:SegmentTree[T]): string =
    var arrs : seq[seq[int]] = @[]
    var l = 0
    var r = 1
    while r <= self.data.len:
      arrs &= self.data[l..<r]
      l = l * 2 + 1
      r = r * 2 + 1
    return $arrs

useSegmentTree()
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let d = scan()
let k = scan()
let S = newSeqWith(n,scan())
var smax = initSegmentTree[int](n,-1e10.int,maximpl[int])
for i in 0..<n: smax[i] = S[i]
var ans = 0
var time = 0
for i in 0..<n:
  if i+d >= n : break
  let v = smax[i+1..i+d] - S[i]
  if v <= ans : continue
  ans = v
  time = i
if ans <= 0 : quit "0",0
echo ans * k
stdout.write time," "
for i in time+1..<n:
  if S[i] == ans + S[time] :
    echo i
    quit 0