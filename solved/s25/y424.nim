import sequtils

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord


let h = scan()
let w = scan()
let (sy,sx) = (scan()-1,scan()-1)
let (gy,gx) = (scan()-1,scan()-1)
var B = newSeqWith(w,newSeqWith(h,0))
for y in 0..<h:
  for x in 0..<w:
    B[x][y] = getchar_unlocked().ord - '0'.ord
  discard getchar_unlocked()

var checked = newSeqWith(w,newSeqWith(h,false))
proc check(x,y:int) =
  if checked[x][y] : return
  checked[x][y] = true
  const dxdy4 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0)]
  for d in dxdy4:
    let nx = x + d.x
    let ny = y + d.y
    if nx < 0 or ny < 0 or nx >= w or ny >= h : continue
    if (B[nx][ny] - B[x][y]).abs > 1: continue
    check(nx,ny)
  for d in dxdy4:
    let nx = x + d.x * 2
    let ny = y + d.y * 2
    if nx < 0 or ny < 0 or nx >= w or ny >= h : continue
    if B[nx][ny] != B[x][y] : continue
    if B[x+d.x][y+d.y] >= B[x][y] : continue
    check(nx,ny)
check(sx,sy)
if checked[gx][gy] : echo "YES"
else: echo "NO"