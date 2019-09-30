import sequtils,math
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  result = 0
  var minus = false
  while true:
    var k = getchar_unlocked()
    if k == '-' : minus = true
    elif k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord
  if minus: result *= -1

type
  SegmentTree[T] = ref object
    n : int
    data:seq[T]
    infinity: T
    cmp:proc(x,y:T):T
proc newSegmentTree[T](size:int,infinity:T) : SegmentTree[T] =
  new(result)
  result.n = size.nextPowerOfTwo()
  result.data = newSeqWith(result.n * 2,infinity)
  result.infinity = infinity
proc `[]=`[T](self:var SegmentTree[T],i:int,val:T) =
  var i = i + self.n - 1
  self.data[i] = val
  while i > 0:
    i = (i - 1) shr 1
    self.data[i] = self.cmp(self.data[i * 2 + 1],self.data[i * 2 + 2])
proc queryImpl[T](self:SegmentTree[T],target,now:Slice[int],i:int) : T =
  if now.b <= target.a or target.b <= now.a : return self.infinity
  if target.a <= now.a and now.b <= target.b : return self.data[i]
  let next = (now.a + now.b) shr 1
  let vl = self.queryImpl(target, now.a..next, i*2+1)
  let vr = self.queryImpl(target, next..now.b, i*2+2)
  return self.cmp(vl,vr)
proc `[]`[T](self:SegmentTree[T],slice:Slice[int]): T =
  return self.queryImpl(slice.a..slice.b+1,0..self.n,0)
proc `[]`[T](self:SegmentTree[T],i:int): T = self[i..i]

proc newAddSegmentTree[T](size:int) : SegmentTree[T] =
  # 区間和のセグツリ
  result = newSegmentTree[T](size,0.int)
  proc addimpl[T](x,y:T): T = x + y
  result.cmp = addimpl[T]


let n = scan()
let k = scan()
const MAX = 100_0001
var cargo =  newAddSegmentTree[int](MAX)
n.times:
  var w = scan()
  if w > 0:
    if cargo[w..<MAX] >= k: continue # W以上の荷物がK個以上
    cargo[w] = cargo[w] + 1
  else:
    w *= -1
    if cargo[w] == 0 : continue # 荷物が無い
    cargo[w] = cargo[w] - 1
echo cargo[0..<MAX]
