import sequtils
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord
const dxdy4 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0)]

let w = scan()
let h = scan()
var M = newSeqWith(w,newSeqUninitialized[int](h))
for y in 0..<h:
  for x in 0..<w:
    M[x][y] = scan()

var already = newSeqWith(w,newSeq[bool](h))
proc dfs(x,y,px,py,m:int) =
  already[x][y] = true
  for d in dxdy4:
    let nx = x + d.x
    let ny = y + d.y
    if nx < 0 or ny < 0 or nx >= w or ny >= h : continue
    if nx == px and ny == py : continue
    if M[nx][ny] != m : continue
    if already[nx][ny] : quit "possible",0
    dfs(nx,ny,x,y,m)

for x in 0..<w:
  for y in 0..<h:
    if not already[x][y] : dfs(x,y,-1,-1,M[x][y])
echo "impossible"
