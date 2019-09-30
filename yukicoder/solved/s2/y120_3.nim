import sequtils,algorithm
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

# SkewHeapNode :: Merge も log(N) な BinaryHeap
type
  SkewHeapNode*[T] = ref object
    L,R: SkewHeapNode[T]
    top*: T
  SkewHeap*[T] = ref object
    root*:SkewHeapNode[T]
    cmp*:proc(x,y:T):int
    size*: int
proc revcmp[T](x,y:T):int = cmp[T](y,x)
proc newSkewHeapNode[T](val:T):SkewHeapNode[T] =
  new(result)
  result.top = val
proc newSkewHeap*[T](cmp:proc(x,y:T):int):SkewHeap[T] =
  new(result)
  result.cmp = cmp
  result.size = 0
proc merge[T](self:var SkewHeap[T],a,b:var SkewHeapNode[T]):SkewHeapNode[T] =
  if a == nil: return b
  if b == nil: return a
  if self.cmp(a.top,b.top) > 0 : swap(a,b)
  a.R = self.merge(a.R,b)
  swap(a.L,a.R)
  return a
proc top*[T](self:SkewHeap[T]): T = self.root.top
proc len*[T](self:SkewHeap[T]): int = self.size
proc isEmpty*[T](self: SkewHeap[T]) : bool = self.len == 0
proc push*[T](self:var SkewHeap[T],val:T) =
  var a = newSkewHeapNode[T](val)
  self.root = self.merge(self.root,a)
  self.size += 1
proc pop*[T](self:var SkewHeap[T]): T =
  result = self.root.top
  self.root = self.merge(self.root.L,self.root.R)
  self.size -= 1
proc merge*[T](self,other:var SkewHeap[T]) : SkewHeap[T] =
  new(result)
  result.size = self.size + other.size
  result.root = self.merge(self.root,other.root)
  result.cmp = self.cmp
  self = nil
  other = nil


proc solve() : int =
  let n = scan()
  var L = newSeq[int](n)
  for i in 0..<n: L[i] = scan()
  L.sort(cmp)
  var R = @[1]
  for i in 1..<n:
    if L[i-1] == L[i] : R[^1] += 1
    else: R .add 1
  if R.len < 3: return 0
  var q = newSkewHeap[int](revcmp)
  for r in R: q.push(r)
  while true:
    let a = q.pop() - 1
    let b = q.pop() - 1
    let c = q.pop() - 1
    if a < 0 or b < 0 or c < 0 : return
    result += 1
    q.push(b)
    q.push(c)
    q.push(a)

scan().times: echo solve()
