import sequtils,algorithm,random,times
# GC_disableMarkAndSweep()
template times*(n:int,body) = (for _ in 0..<n: body)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

type
  Heap*[T] = object
    nodes: seq[T]
    compare: proc(x,y:T):int
proc newHeap*[T](compare:proc(x,y:T):int): Heap[T] = Heap[T](nodes:newSeq[T](),compare:compare)
proc compareNode[T](h:Heap[T],i,j:int): int {.inline.}= h.compare(h.nodes[i],h.nodes[j])
proc size*[T](h:Heap[T]):int = h.nodes.len()
proc items*[T](h:Heap[T]):seq[T] = h.nodes
proc top*[T](h:Heap[T]): T = h.nodes[0]
proc push*[T](h:var Heap[T],node:T):void =
  h.nodes.add(node) #末尾に追加
  var i = h.nodes.len() - 1
  while i > 0: # 末尾から木を整形
    let parent = (i - 1) div 2
    if h.compare(h.nodes[parent],node) <= 0: break
    h.nodes[i] = h.nodes[parent]
    i = parent
  h.nodes[i] = node
proc shiftdown*[T](h:var Heap[T]): void =
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

proc pop*[T](h:var Heap[T]):T =
  result = h.nodes[0] # rootと末尾を入れ替えて木を整形
  h.nodes[0] = h.nodes[^1]
  h.nodes.setLen(h.nodes.len() - 1)
  h.shiftdown()
proc replaceTop*[T](h:var Heap[T],node:T):void =
  h.nodes[0] = node
  h.shiftdown()

let n = scan()
# 一番レベルの低い 一番戦ってないものを戦わせる
type monster = tuple[lv:int,cnt:int]
var myInitialHeap = newHeap(
  proc (a,b:monster):int =
    if a.lv == b.lv : a.cnt - b.cnt
    else: a.lv - b.lv
  )
let A = newSeqWith(n,scan()).sorted(cmp)
let B = newSeqWith(n,scan() shr 1) # enemy
for i in 0..<n : myInitialHeap.push((A[i] ,0))
let startedTime = cpuTime()
var i = 0
var ans = 1e12.int
while true:
  var myHeap = myInitialHeap
  var mx = 0
  for j in 0..<n:
    let b = B[(j + i) mod n]
    var me = myHeap.top()
    me.lv += b
    me.cnt += 1
    myHeap.replaceTop(me)
    if me.cnt > mx :
      mx = me.cnt
      if ans <= mx: break
  ans .min= mx
  i += 1
  if i >= n : break
  if (cpuTime() - startedTime) * 1000 > 90: break
echo ans
