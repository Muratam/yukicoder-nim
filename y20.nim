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
# 0以下で死亡 / V - Lxy => Oasis(v *= 2,once)
# N <= 200, V <= 500, Lxy <= 9
# x:N * y:N * use:2 => V
# 最短でゴール or 最短でオアシス +最短でゴールのみ
let
  (N,V,oax,oay) = get().split().map(parseInt).unpack(4)
  L = newSeqWith(N,get().strip().split().map(parseInt)).transpose()
  (ox,oy) = (oax-1,oay-1)
#[
## とりあえずダイクストラ ##########################################
proc dijkestra(sx,sy:int, L:seq[seq[int]],diffSeq:seq[tuple[x,y:int]]):auto =
  type field = tuple[x,y,v:int]
  let (W,H) = (L.len,L[0].len)
  const INF = int.high div 4
  var cost = newSeqWith(W,newSeqWith(H,INF))
  var opens = newBinaryHeap[field](proc(a,b:field): int = a.v - b.v)
  opens.push((sx,sy,0))
  while opens.size() > 0:
    let (x,y,v) = opens.pop()
    if cost[x][y] != INF : continue
    cost[x][y] = v
    for d in diffSeq:
      let (nx,ny) = (d.x + x,d.y + y)
      if nx < 0 or ny < 0 or nx >= W or ny >= H : continue
      var n_v = v + L[nx][ny]
      if cost[nx][ny] == INF :
        opens.push((nx,ny,n_v))
  return cost

let
  b2cost = dijkestra(0,0,L,dxdy4)
  b2e = b2cost[N-1][N-1]
if ox == -1 and oy == -1 :
  if V - b2e > 0: echo "YES"
  else: echo "NO"
else:
  let
    b2o = b2cost[ox][oy]
    o2cost = dijkestra(ox,oy,L,dxdy4)
    o2e = o2cost[N-1][N-1]
  if V - b2e > 0 or 2 * (V - b2o) - o2e > 0 :
    echo "YES"
  else: echo "NO"
]#
############## 二段階にわける (27ms:結局全探索しないといけないものには勝てない) #####################

proc twoFactorDijkestra(sx,sy,sv:int,checkOasis:bool = true):void =
  type field = tuple[x,y,v:int]
  var closed = newSeqWith(N,newSeqWith(N,false))
  var opens = newBinaryHeap[field]( proc(a,b:field): int = -a.v + b.v)
  opens.push((sx,sy,sv))
  while opens.size() > 0:
    let (x,y,v) = opens.pop()
    if closed[x][y] : continue
    closed[x][y] = true
    if checkOasis and x == ox and y == oy:
      twoFactorDijkestra(x,y,v * 2,false)
      continue
    for d in dxdy4:
      let (nx,ny) = (d.x + x,d.y + y)
      if nx < 0 or ny < 0 or nx >= N or ny >= N : continue
      var n_v = v - L[nx][ny]
      if n_v <= 0 : continue
      if not closed[nx][ny]:
        opens.push((nx,ny,n_v))
        if nx == N-1 and ny == N-1:
          echo "YES"
          quit()
twoFactorDijkestra(0,0,V)
echo "NO"

#[
############## use dijekstra all in one (33ms) ###############
type field = tuple[x,y,used,v:int]
var closed = newSeqWith(N,newSeqWith(N,[false,false]))
var opens = newBinaryHeap[field](
  proc(a,b:field): int = #-a.v + b.v
    if a.used != b.used : - a.used + b.used # オアシスを使ったほうが強い
    else : -a.v + b.v
    #elif a.v != b.v : - a.v + b.v # 基本は体力をコスト関数とする
    #else: - (a.x + a.y) + (b.x + b.y)
)
opens.push((0,0,false.int,V))

proc dijkstra():void =
  while opens.size() > 0:
    let (x,y,used,v) = opens.pop()
    if closed[x][y][used] : continue
    closed[x][y][used] = true
    #echo((x:x,y:y,u:used,v:v))
    for d in dxdy4:
      let (nx,ny) = (d.x + x,d.y + y)
      if nx < 0 or ny < 0 or
        nx >= N or ny >= N : continue
      var
        n_used = used
        n_v = v - L[nx][ny]
      if n_v <= 0 : continue
      if nx == ox and ny == oy and (not used.bool):
        n_used = true.int
        n_v *= 2
      if not closed[nx][ny][n_used]:
        opens.push((nx,ny,n_used,n_v))
        if nx == N-1 and ny == N-1:
          echo "YES"
          quit()
dijkstra()
echo "NO"
]#
#[
########### DP ( 533ms )  ###########################
var dp = newSeqWith(N,newSeqWith(N,[OPEN,OPEN]))
proc dp_seek(x,y,used:int): void =
  if x == N-1 and y == N-1:
    echo "YES"
    quit()
  for d in dxdy4:
    let (nx,ny) = (d.x + x,d.y + y)
    if nx < 0 or ny < 0 or
       nx >= N or ny >= N : continue
    var
      n_used = used
      v = dp[x][y][used] - L[nx][ny]
    if isOasis(nx,ny) and (not used.bool):
      n_used = true.int
      v *= 2
    if dp[nx][ny][n_used] < v and v > 0:
      dp[nx][ny][n_used] = v
      dp_seek(nx,ny,n_used)
dp_seek(0,0,false.int)
echo "NO"
]#
