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

template useBinaryHeap() = # 追加 / 最小値検索 / 最小値Pop O(log(N))
  type
    BinaryHeap*[T] = ref object
      nodes: seq[T]
      compare: proc(x,y:T):int
      popchunk: bool
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
  proc push*[T](h:var BinaryHeap[T],node:T):void =
    if h.popchunk :
      h.nodes[0] = node
      h.shiftdown()
    else: h.pushimpl(node)
  proc pop*[T](h:var BinaryHeap[T]):T =
    if h.popchunk: discard h.popimpl()
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

useBinaryHeap()

# 0以下で死亡 / V - Lxy => Oasis(v *= 2,once)
# N <= 200, V <= 500, Lxy <= 9
# x:N * y:N * use:2 => V
# 最短でゴール or 最短でオアシス +最短でゴールのみ
let n = scan()
let v = scan()
let ox = scan() - 1
let oy = scan() - 1
var L = newSeqWith(n,newSeqUninitialized[int](n))
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
  while opens.size > 0:
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