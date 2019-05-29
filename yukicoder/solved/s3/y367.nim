import sequtils,times#,nimprof
type Pos = tuple[x,y:int16]
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeline "TIME:",(cpuTime() - t1) * 1000,"ms")
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord
let h = scan()
let w = scan()
var M : array[500,array[500,bool]]
const INF = int16.high
var DP : array[500,array[500,array[2,int16]]]
var s : Pos
var g : Pos
for y in 0..<h:
  for x in 0..<w:
    let k = getchar_unlocked()
    if k == 'S' : s = (x.int16,y.int16)
    elif k == 'G' : g = (x.int16,y.int16)
    M[x][y] = k == 'R'
  discard getchar_unlocked()
DP[s.x][s.y][0] = -INF
type Queue[CNT:static[int],T] = object
  data : array[CNT,T]
  l,r:int
template enqueue[CNT,T](q:var Queue[CNT,T],val:T) =
  q.data[q.r] = val
  q.r += 1
proc dequeue[CNT,T](q:var Queue[CNT,T]) : T =
  q.l += 1
  return q.data[q.l - 1]
template size[CNT,T](q:var Queue[CNT,T]) : int = q.r - q.l

var Q : Queue[500*500*2+100,uint64] # tuple[x,y,isKnight,d:int16]
template en(a,b,c,d:int16):uint64 = (cast[uint64](a) shl 48) or (cast[uint64](b) shl 32) or (cast[uint32](c) shl 16) or cast[uint16](d)
Q.enqueue(en(s.x,s.y,1.int16,-INF))
let D : seq[seq[Pos]] = @[
  @[(1,1),(-1,-1),(1,-1),(-1,1)],
  @[(1,2),(2,1),(-1,-2),(-2,-1),(-1,2),(-2,1),(1,-2),(2,-1)],
].mapIt(it.mapIt((it[0].int16,it[1].int16)))
proc sign(n:int):int = (if n < 0 : -1 else: 1)
let D2  : seq[seq[Pos]] = @[
  @[(1,1)],
  @[(1,2),(2,1)],
].mapIt(it.mapIt(((it[0] * sign(g.x - s.x)).int16,(it[1] * sign(g.y - s.y)).int16)))
stopwatch:
  proc solve() : bool  =
    while Q.size() > 0:
      let qe = Q.dequeue()
      let x = cast[int16](qe shr 48)
      let y = cast[int16](qe shr 32)
      let isKnight = cast[int16](qe shr 16)
      let diff = cast[int16](qe)
      let nextDiff = diff + 1
      if w > 400 and h > 400 and abs(x - w) > 50 and abs(y - h) > 50 and 3 < x and x < w - 4 and 3 < y and y < h - 4:
        for i in 0..<(1 + isKnight):
          let nx = x + D2[isKnight][i].x
          let ny = y + D2[isKnight][i].y
          if nx == g.x and ny == g.y :
            echo nextDiff + INF
            return true
          let nextIsKnight = if M[nx][ny]: 1 - isKnight else: isKnight
          if DP[nx][ny][nextIsKnight] <= nextDiff: continue
          DP[nx][ny][nextIsKnight] = nextDiff
          Q.enqueue(en(nx,ny,nextIsKnight,nextDiff))
      else:
        for i in 0..<(4 + isKnight * 4):
          let nx = x + D[isKnight][i].x
          let ny = y + D[isKnight][i].y
          if nx < 0 or ny < 0 or nx >= w or ny >= h : continue
          if nx == g.x and ny == g.y :
            echo nextDiff + INF
            return true
          let nextIsKnight = if M[nx][ny]: 1 - isKnight else: isKnight
          if DP[nx][ny][nextIsKnight] <= nextDiff: continue
          DP[nx][ny][nextIsKnight] = nextDiff
          Q.enqueue(en(nx,ny,nextIsKnight,nextDiff))
    return false
  if not solve(): echo -1