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

let
  (N,V,sx,sy,gx,gy) = get().split().map(parseInt).unpack(6)
  L = newSeqWith(N,get().strip().split().map(parseInt)).transpose()

# 幅優先でよい
proc seek(sx,sy:int, L:seq[seq[int]],diffSeq:seq[tuple[x,y:int]]):auto =
  type field = tuple[x,y,v,c:int]
  let (W,H) = (L.len,L[0].len)
  const INF = int.high div 4
  var cost = newSeqWith(W,newSeqWith(H,INF))
  var opens = initQueue[field]()
  opens.enqueue((sx,sy,0,0))
  cost[sx][sy] = 0
  while opens.len() > 0:
    let (x,y,v,c) = opens.dequeue()
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
        opens.enqueue((nx,ny,n_v,c+1))

seek(sx-1,sy-1,L,dxdy4)
echo -1

# Sxy => Gxy 死なずに最も早く()