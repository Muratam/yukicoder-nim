import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables,lists,random
template get():string = stdin.readLine()
template times(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template `max=`(x,y:typed):void = x = max(x,y)
template `min=`(x,y:typed):void = x = min(x,y)


type
  Heap*[T] = object
    nodes: seq[T]
    compare: proc(x,y:T):int
proc newHeap*[T](compare:proc(x,y:T):int): Heap[T] =
  Heap[T](nodes:newSeq[T](),compare:compare)
proc size*[T](h:Heap[T]):int = h.nodes.len()
proc items*[T](h:Heap[T]):seq[T] = h.nodes
proc top*[T](h:Heap[T]): T = h.nodes[0]
proc push*[T](h:var Heap[T],node:T):void =
  h.nodes.add(node) #末尾に追加
  var i = h.nodes.len()
  while i > 0: # 末尾から木を整形
    let parent = (i - 1) div 2
    if h.compare(h.nodes[parent],node) <= 0: break
    h.nodes[i] = h.nodes[parent]
    i = parent
  h.nodes[i] = node
proc pop*[T](h:var Heap[T]):T =
  result = h.nodes[0] # rootと末尾を入れ替えて木を整形
  h.nodes[0] = h.nodes[^1]
  h.nodes.setLen(h.nodes.len() - 1)
  let size = h.nodes.len()
  var i = 0
  while true :
    let L = i * 2 + 1
    let R = i * 2 + 2
    if L >= size : break
    let child = if R < size and h.compare(h.nodes[R],h.nodes[L]) <= 0 : R else: L
    if h.compare(h.nodes[i],h.nodes[child]) <= 0: break
    swap(h.nodes[i],h.nodes[child])
    i = child


let
  N = get().parseInt # ~1500
  A = get().split().map(parseInt) # my lv
  B = get().split().map(parseInt) #enemy lv

# 一番レベルの低い 一番戦ってないものを戦わせる
type monster = tuple[lv:int,cnt:int]
var myInitialHeap = newHeap(
  proc (a,b:monster):int =
    if a.lv == b.lv : a.cnt - b.cnt
    else: a.lv - b.lv )
for a in A: myInitialHeap.push((a,0))
var res = 1e12.int
for i in 0..<N:
  var myHeap = myInitialHeap
  var mx = 0
  for j in 0..<N: # 1500 * 1500 * log(1500)
    let b = B[(i + j) mod N]
    var me = myHeap.pop()
    me.lv += b div 2  # (b div 2)ぶんレベルアップ
    me.cnt += 1
    myHeap.push(me)
    if me.cnt > mx :
      mx = me.cnt
      if res <= mx: break
  res .min= mx
echo res

