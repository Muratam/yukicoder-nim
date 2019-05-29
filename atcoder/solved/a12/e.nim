import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

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
    infinity:T = int(1e10)) : SegmentTree[T] =
  new(result)
  result.infinity = infinity
  result.cmp = minimpl[T]
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

let n = scan() # 2*10^5
let q = scan() # 2*10^5
let STX = newSeqWith(n,(s:scan(),t:scan(),x:scan()))
let D = newSeqWith(q,scan())

# var T = newSegmentTree[int](100) # WARN
const INF = 1e10.int
var P = newSeqWith(10000,INF)
for stx in STX:
  let (s,t,x) = stx
  for i in 0.max(s-x)..t-x-1:
    P[i] .min= x
for d in D:
  if P[d] == INF: echo -1
  else: echo P[d]
