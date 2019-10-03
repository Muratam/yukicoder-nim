import sequtils,strutils,algorithm
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y)= (x = max(x,y))
template `min=`*(x,y)= (x = min(x,y))

const dxdy4 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0)]

import algorithm

import algorithm
type BinaryHeap*[T] = ref object
  data*: seq[T]
  cmp*:proc(x,y:T):int
proc revcmp[T](x,y:T):int = cmp[T](y,x)
proc `[]`[T](heap: BinaryHeap[T], i: Natural): T {.inline.}= heap.data[i]
proc siftdown[T](heap: var BinaryHeap[T], startpos, p: int) =
  var pos = p
  var newitem = heap[pos]
  while pos > startpos:
    let parentpos = (pos - 1) shr 1
    let parent = heap[parentpos]
    if 0 <= heap.cmp(newitem, parent): break
    heap.data[pos] = parent
    pos = parentpos
  heap.data[pos] = newitem
proc siftup[T](heap: var BinaryHeap[T], p: int) =
  let endpos = len(heap)
  var pos = p
  let startpos = pos
  let newitem = heap[pos]
  var childpos = 2*pos + 1
  while childpos < endpos:
    let rightpos = childpos + 1
    if rightpos < endpos and 0 <= heap.cmp(heap[childpos], heap[rightpos]):
      childpos = rightpos
    heap.data[pos] = heap[childpos]
    pos = childpos
    childpos = 2*pos + 1
  heap.data[pos] = newitem
  siftdown(heap, startpos, pos)

proc len*[T](heap: BinaryHeap[T]): int = heap.data.len
proc push*[T](heap: var BinaryHeap[T], item: T) =
  heap.data.add(item)
  siftdown(heap, 0, len(heap)-1)
proc pop*[T](heap: var BinaryHeap[T]): T =
  let lastelt = heap.data.pop()
  if heap.len > 0:
    result = heap[0]
    heap.data[0] = lastelt
    siftup(heap, 0)
  else:
    result = lastelt
proc top*[T](heap: var BinaryHeap[T]): T = heap.data[0]
proc poppush*[T](heap: var BinaryHeap[T], item: T): T =
  result = heap[0]
  heap.data[0] = item
  siftup(heap, 0)
proc pushpop*[T](heap: var BinaryHeap[T], item: T): T =
  if heap.len > 0 and 0 > heap.cmp(heap[0], item):
    swap(item, heap[0])
    siftup(heap, 0)
  return item
proc clear*[T](heap: var BinaryHeap[T]) = heap.data.setLen(0)
proc toSeq*[T](heap: BinaryHeap[T]): seq[T] = heap.data.sorted(cmp)
proc `$`*[T](heap: BinaryHeap[T]): string = $heap.toSeq()
iterator items*[T](heap:BinaryHeap[T]) : T =
  for v in heap.toSeq(): yield v
proc newBinaryHeap*[T](cmp:proc(x,y:T):int) : BinaryHeap[T]=
  new(result)
  result.data = @[]
  result.cmp = cmp


# 0以下で死亡 / V - Lxy => Oasis(v *= 2,once)
# N <= 200, V <= 500, Lxy <= 9
# x:N * y:N * use:2 => V
# 最短でゴール or 最短でオアシス +最短でゴールのみ
let n = scan()
let v = scan()
let ox = scan() - 1
let oy = scan() - 1
var L = newSeq[seq[int]](n)
for x in 0..<n: L[x] = newSeqUninitialized[int](n)
for y in 0..<n:
  for x in 0..<n:
    L[x][y] = scan()
type Field = ref object
   x,y,v:int
proc newField(x,y,v:int):Field=
  new(result)
  result.x = x
  result.y = y
  result.v = v

proc twoFactorDijkestra(sx,sy,sv:int,checkOasis:bool = true):void =
  var closed = newSeqWith(n,newSeq[bool](n))
  var opens = newBinaryHeap[Field](proc (x,y:Field) : int = - x.v + y.v)
  opens.push(newField(sx,sy,sv))
  while opens.len > 0:
    let field = opens.pop()
    let x = field.x
    let y = field.y
    let v = field.v
    if closed[x][y] : continue
    closed[x][y] = true
    if checkOasis and x == ox and y == oy:
      twoFactorDijkestra(x,y,v * 2,false)
      continue
    for d in dxdy4:
      let (nx,ny) = (d.x + x,d.y + y)
      if nx < 0 or ny < 0 or nx >= n or ny >= n : continue
      var n_v = v - L[nx][ny]
      if n_v <= 0 : continue
      if not closed[nx][ny]:
        opens.push(newField(nx,ny,n_v))
        if nx == n-1 and ny == n-1:
          quit "YES",0
twoFactorDijkestra(0,0,v)
echo "NO"
