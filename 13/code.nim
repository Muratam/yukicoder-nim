import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables,macros
macro unpack*(rhs: seq,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `rhs`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template get*():string = stdin.readLine()
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template `max=`*(x,y:typed):void = x = max(x,y)
template `min=`*(x,y:typed):void = x = min(x,y)
proc transpose[T](mat:seq[seq[T]]):seq[seq[T]] =
  result = newSeqWith(mat[0].len,newSeq[T](mat.len))
  for x,xs in mat: (for y,ys in xs:result[y][x] = mat[x][y])

let (W,H) = get().split().map(parseInt).unpack(2)
let stages = newSeqWith(H,get().split().map(parseInt)).transpose()
var colors = newSeqWith(W,newSeqWith(H,0))
var currentColor = 0 # currentColor

for x in 0..<W:
  for y in 0..<H:
    if colors[x][y] != 0: continue
    currentColor += 1
    let num = stages[x][y]
    proc dfs(x,y,prex,prey: int) :void =
      colors[x][y] = currentColor
      for d in [(1,0),(0,1),(-1,0),(0,-1)]:
        let (dx,dy) = d
        let (nx,ny) = (x+dx,y+dy)
        if nx >= W or ny >= H or
            nx < 0  or ny < 0 : continue
        if nx == prex and ny == prey : continue
        if stages[nx][ny] != num: continue
        if colors[nx][ny] != currentColor:
          colors[nx][ny] = currentColor
          dfs(nx,ny,x,y)
        else:
          echo "possible"
          quit()
    dfs(x,y,-1,-1)
echo "impossible"