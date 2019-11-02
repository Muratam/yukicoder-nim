{.checks:off.}
# Queue
import math
type
  Queue*  [T] = object ## A queue.
    data: seq[T]
    rd, wr, count, mask: int
proc initQueue*[T](initialSize: int = 4): Queue[T] =
  assert isPowerOfTwo(initialSize)
  result.mask = initialSize-1
  newSeq(result.data, initialSize)
proc len*[T](q: Queue[T]): int {.inline.}= q.count
proc top*[T](q: Queue[T]): T {.inline.}= q.data[q.rd]
iterator pairs*[T](q: Queue[T]): tuple[key: int, val: T] =
  var i = q.rd
  for c in 0 ..< q.count:
    yield (c, q.data[i])
    i = (i + 1) and q.mask
proc add*[T](q: var Queue[T], item: T) =
  var cap = q.mask+1
  if unlikely(q.count >= cap):
    var n = newSeq[T](cap*2)
    for i, x in pairs(q):
      shallowCopy(n[i], x)
    shallowCopy(q.data, n)
    q.mask = cap*2 - 1
    q.wr = q.count
    q.rd = 0
  inc q.count
  q.data[q.wr] = item
  q.wr = (q.wr + 1) and q.mask
template default[T](t: typedesc[T]): T =
  var v: T
  v
proc pop*[T](q: var Queue[T]): T {.inline, discardable.} =
  dec q.count
  result = q.data[q.rd]
  q.data[q.rd] = default(type(result))
  q.rd = (q.rd + 1) and q.mask
# impl
import sequtils,algorithm,math,tables,sets,strutils,times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
template loop*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord
type Pos = tuple[x,y:int]
type Robot = tuple[pos,dir:Pos]
type Block = enum Empty,BGoal,BBlock,BL,BR,BU,BD
const dp4 : seq[Pos] = @[(-1,0),(1,0),(0,-1),(0,1)]
proc toDir(b:Block):Pos =
  if b == BL : return (-1,0)
  if b == BR : return (1,0)
  if b == BU : return (0,-1)
  if b == BD : return (0,1)
  assert false
proc fromDir(d:Pos):Block =
  assert d.x.abs + d.y.abs == 1
  if d.x == -1: return BL
  if d.x == 1 : return BR
  if d.y == -1 : return BU
  if d.y == 1 : return BD
  assert false
proc scanPos():Pos =
  let y = scan()
  let x = scan()
  return (x,y)
proc scanRobot() : Robot =
  let y = scan()
  let x = scan()
  let c = getchar_unlocked()
  discard getchar_unlocked()
  let dir : Pos =
    case c:
    of 'U':(0,-1)
    of 'D':(0,1)
    of 'L':(-1,0)
    of 'R':(1,0)
    else:(0,0)
  doAssert dir.x.abs + dir.y.abs == 1
  return ((x,y),dir)
proc `$`(b:Block): string =
  return case b:
    of Empty: " "
    of BGoal: "G"
    of BBlock: "B"
    of BU: "U"
    of BD: "D"
    of BL: "L"
    of BR: "R"
proc printAnswer(mat:var seq[seq[Block]]) =
  type Put = tuple[pos:Pos,kind:Block]
  var puts = newSeq[Put]()
  for x in 0..<mat.len:
    for y in 0..<mat[x].len:
      let k = mat[x][y]
      if k in [Empty,BGoal,BBlock]: continue
      puts.add(((x,y),k))
  echo puts.len
  for p in puts:
    echo p.pos.y," ",p.pos.x," ",p.kind
let n = scan() # 40x40
proc `+`(a,b:Pos):Pos =
  ((((a.x+b.x) mod n) + n) mod n,
   (((a.y+b.y) mod n) + n) mod n)
proc `-`(a:Pos):Pos = (-a.x,-a.y)
proc `[]`[T](m:var seq[seq[T]],a:Pos): T = m[a.x][a.y]
proc `[]=`[T](m:var seq[seq[T]],a:Pos,v:T) = m[a.x][a.y] = v
let m = scan() # 100
let b = scan() # 300
let goal = scanPos()
let robots = newSeqWith(m,scanRobot())
let blocklist = newSeqWith(b,scanPos())
var mat = newSeqWith(n,newSeqWith(n,Empty)) # 床
var initRobMat = newSeqWith(n,newSeqWith(n,Empty)) # ロボットの初期位置
block: # make mat
  mat[goal] = BGoal
  for b in blocklist:
    mat[b] = BBlock
  for r in robots:
    initRobMat[r.pos] = r.dir.fromDir()
# とりあえず正解を置く
proc bfs() =
  type PosKind = tuple[pos:Pos,kind:Block]
  var q = initQueue[PosKind]()
  for d in dp4:
    let next = goal + d
    if mat[next] != Empty: continue
    q.add((next,(-d).fromDir))
  while q.len > 0:
    let (now,kind) = q.pop()
    if mat[now] != Empty: continue
    mat[now] = kind
    for d in dp4:
      let next = now + d
      if mat[next] != Empty: continue
      q.add((next,(-d).fromDir))
# 通らない道は消す
proc simplify() =
  var route = newSeqWith(n,newSeqWith(n,false))
  for r in robots:
    var p = r.pos
    # ゴール不可能
    if mat[p] == Empty: continue
    while mat[p] != BGoal:
      route[p] = true
      p = p + mat[p].toDir
  for x in 0..<n:
    for y in 0..<n:
      let p : Pos = (x,y)
      if route[p]: continue
      if mat[p] in [BL,BR,BU,BD]:
        mat[p] = Empty


bfs()
simplify()
mat.printAnswer()
