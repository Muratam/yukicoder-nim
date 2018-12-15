{.checks: off, optimization: speed.}
import sequtils,strutils,strscans,algorithm,math,sugar,sets,queues,tables,macros
import heapqueue
macro unpack*(rhs: seq,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `rhs`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template get*():string = stdin.readLine()
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y)= (x = max(x,y))
template `min=`*(x,y)= (x = min(x,y))

proc transpose*[T](mat:seq[seq[T]]):seq[seq[T]] =
  result = newSeqWith(mat[0].len,newSeq[T](mat.len))
  for x,xs in mat: (for y,ys in xs:result[y][x] = mat[x][y])
const dxdy4 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0)]

# 0以下で死亡 / V - Lxy => Oasis(v *= 2,once)
# N <= 200, V <= 500, Lxy <= 9
# x:N * y:N * use:2 => V
# 最短でゴール or 最短でオアシス +最短でゴールのみ
let
  (N,V,oax,oay) = get().split().map(parseInt).unpack(4)
  L = newSeqWith(N,get().strip().split().map(parseInt)).transpose()
  (ox,oy) = (oax-1,oay-1)
############## 二段階にわける #####################
type field = tuple[x,y,v:int]
proc `<`(x,y:field):bool = (x.v > y.v)
proc twoFactorDijkestra(sx,sy,sv:int,checkOasis:bool = true):void =
  var closed = newSeqWith(N,newSeqWith(N,false))
  var opens = newHeapQueue[field]()
  opens.push((sx,sy,sv))
  while opens.len() > 0:
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