import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord

# PriorytyQueue
# 追加 / 最小値検索 / 最小値Pop O(log(N))
type
  BinaryHeap*[T] = ref object
    nodes: seq[T]
    compare: proc(x,y:T):int
    popchunk: bool

proc revcmp[T](x,y:T):int = cmp[T](y,x)
proc newBinaryHeap*[T](compare:proc(x,y:T):int): BinaryHeap[T] =
  new(result)
  result.nodes = newSeq[T]()
  result.compare = compare
proc compareNode[T](h:BinaryHeap[T],i,j:int):int = h.compare(h.nodes[i],h.nodes[j])
proc size*[T](h:BinaryHeap[T]):int = h.nodes.len() - h.popchunk.int
proc items*[T](h:var BinaryHeap[T]):seq[T] =
  if h.popchunk : discard h.popimpl()
  return h.nodes
proc top*[T](h:var BinaryHeap[T]): T =
  if h.popchunk : discard h.popimpl()
  return h.nodes[0]

proc shiftdown[T](h:var BinaryHeap[T]): void =
  h.popchunk = false
  let size = h.nodes.len()
  var i = 0
  while true :
    let L = i * 2 + 1
    let R = i * 2 + 2
    if L >= size : break
    let child = if R < size and h.compareNode(R,L) <= 0 : R else: L
    if h.compareNode(i,child) <= 0: break
    swap(h.nodes[i],h.nodes[child])
    i = child

proc pushimpl[T](h:var BinaryHeap[T],node:T):void =
  h.nodes.add(node) #末尾に追加
  var i = h.nodes.len() - 1
  while i > 0: # 末尾から木を整形
    let parent = (i - 1) div 2
    if h.compare(h.nodes[parent],node) <= 0: break
    h.nodes[i] = h.nodes[parent]
    i = parent
  h.nodes[i] = node

proc popimpl[T](h:var BinaryHeap[T]):T =
  result = h.nodes[0] # rootと末尾を入れ替えて木を整形
  h.nodes[0] = h.nodes[^1]
  h.nodes.setLen(h.nodes.len() - 1)
  h.shiftdown()

proc push*[T](h:var BinaryHeap[T],node:T):void =
  if h.popchunk :
    h.nodes[0] = node
    h.shiftdown()
  else: h.pushimpl(node)
proc pop*[T](h:var BinaryHeap[T]):T =
  if h.popchunk: discard h.popimpl()
  h.popchunk = true
  return h.nodes[0]



let n = scan()
let A = newSeqWith(n,scan())
var bp = newBinaryHeap[int](cmp)
var ans = 1
bp.push(A[0])
for a in A[1..^1]:
  if a > bp.top():
    bp.pop
  else:
    bp.pop()
  bp.push(a)


var plus = 0
var ans = 1
for i in 1..<n:
  if A[i-1] >= A[i]:
    plus -= 1
    if plus < 0:
      ans += 1
      plus = 0
  else:
    plus += 1
echo ans
