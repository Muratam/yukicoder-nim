import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables,macros
macro unpack*(rhs: seq,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `rhs`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template get*():string = stdin.readLine()
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template `max=`*(x,y:typed):void = x = max(x,y)
template `min=`*(x,y:typed):void = x = min(x,y)

proc transpose*[T](mat:seq[seq[T]]):seq[seq[T]] =
  result = newSeqWith(mat[0].len,newSeq[T](mat.len))
  for x,xs in mat: (for y,ys in xs:result[y][x] = mat[x][y])
const dxdy4 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0)]


######################## Binary Heap #############################
type
  BinaryHeap*[T] = object
    nodes: seq[T]
    compare: proc(x,y:T):int
    popchunk: bool
proc newBinaryHeap*[T](compare:proc(x,y:T):int): BinaryHeap[T] =
  BinaryHeap[T](nodes:newSeq[T](),compare:compare,popchunk:false)
proc compareNode[T](h:BinaryHeap[T],i,j:int):int = h.compare(h.nodes[i],h.nodes[j])
proc size*[T](h:BinaryHeap[T]):int = h.nodes.len() - h.popchunk.int
proc items*[T](h:var BinaryHeap[T]):seq[T] =
  if h.popchunk : discard h.popimpl()
  return h.nodes
proc top*[T](h:var BinaryHeap[T]): T =
  if h.popchunk : discard h.popimpl()
  return h.nodes[0]
proc push*[T](h:var BinaryHeap[T],node:T):void =
  if h.popchunk :
    h.nodes[0] = node
    h.shiftdown()
  else: h.pushimpl(node)
proc pop*[T](h:var BinaryHeap[T]):T =
  if h.popchunk:
    discard h.popimpl()
  h.popchunk = true
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
######################## Binary Heap #############################

let
  (N,V,sx,sy,gx,gy) = get().split().map(parseInt).unpack(6)
  L = newSeqWith(N,get().strip().split().map(parseInt)).transpose()


proc seek(sx,sy:int, L:seq[seq[int]],diffSeq:seq[tuple[x,y:int]]):auto =
  type field = tuple[x,y,v,c:int]
  let (W,H) = (L.len,L[0].len)
  const INF = int.high div 4
  var cost = newSeqWith(W,newSeqWith(H,INF))
  var opens = newBinaryHeap[field](proc(a,b:field): int = a.c - b.c)
  opens.push((sx,sy,0,0))
  cost[sx][sy] = 0
  while opens.size() > 0:
    let (x,y,v,c) = opens.pop()
    if cost[x][y] < v : continue
    for d in diffSeq:
      let (nx,ny) = (d.x + x,d.y + y)
      if nx < 0 or ny < 0 or nx >= W or ny >= H : continue
      var n_v = v + L[nx][ny]
      if n_v >= V : continue
      if nx == gx-1 and ny == gy-1:
        echo c+1
        quit()
      if n_v < cost[nx][ny] :
        cost[nx][ny] = n_v
        opens.push((nx,ny,n_v,c+1))

seek(sx-1,sy-1,L,dxdy4)
echo -1

# Sxy => Gxy 死なずに最も早く


