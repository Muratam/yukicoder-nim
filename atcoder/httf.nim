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
# Priority Queue
import algorithm
type PriorityQueue*[T] = ref object
  data*: seq[T]
  cmp*:proc(x,y:T):int
proc ascending*[T](x,y:T):int = (x - y).int # 最小値
proc descending*[T](x,y:T):int = (y - x).int # 最大値
proc `[]`[T](heap: PriorityQueue[T], i: Natural): T {.inline.}= heap.data[i]
proc siftdown[T](heap: var PriorityQueue[T], startpos, p: int) =
  var pos = p
  var newitem = heap[pos]
  while pos > startpos:
    let parentpos = (pos - 1) shr 1
    let parent = heap[parentpos]
    if 0 <= heap.cmp(newitem, parent): break
    heap.data[pos] = parent
    pos = parentpos
  heap.data[pos] = newitem
proc siftup[T](heap: var PriorityQueue[T], p: int) =
  let endpos = len(heap)
  var pos = p
  let startpos = pos
  let newitem = heap[pos]
  var childpos = 2 * pos + 1
  while childpos < endpos:
    let rightpos = childpos + 1
    if rightpos < endpos and 0 <= heap.cmp(heap[childpos], heap[rightpos]):
      childpos = rightpos
    heap.data[pos] = heap[childpos]
    pos = childpos
    childpos = 2 * pos + 1
  heap.data[pos] = newitem
  siftdown(heap, startpos, pos)
proc len*[T](heap: PriorityQueue[T]): int = heap.data.len
proc add*[T](heap: var PriorityQueue[T], item: T) =
  heap.data.add(item)
  siftdown(heap, 0, len(heap)-1)
proc pop*[T](heap: var PriorityQueue[T]): T {.discardable.} =
  let lastelt = heap.data.pop()
  if heap.len > 0:
    result = heap[0]
    heap.data[0] = lastelt
    siftup(heap, 0)
  else:
    result = lastelt
proc top*[T](heap: PriorityQueue[T]): T = heap.data[0]
proc poppush*[T](heap: var PriorityQueue[T], item: T): T =
  result = heap[0]
  heap.data[0] = item
  siftup(heap, 0)
proc pushpop*[T](heap: var PriorityQueue[T], item: T): T =
  if heap.len > 0 and 0 > heap.cmp(heap[0], item):
    swap(item, heap[0])
    siftup(heap, 0)
  return item
proc clear*[T](heap: var PriorityQueue[T]) = heap.data.setLen(0)
proc toSequence*[T](heap: PriorityQueue[T]): seq[T] = heap.data.sorted(cmp)
proc `$`*[T](heap: PriorityQueue[T]): string = $heap.toSequence()
iterator items*[T](heap:PriorityQueue[T]) : T =
  for v in heap.toSequence(): yield v
proc newPriorityQueue*[T](cmp:proc(x,y:T):int) : PriorityQueue[T] =
  new(result)
  result.data = @[]
  result.cmp = cmp
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
const arrow4 : seq[Block] = @[BL,BR,BU,BD]
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
type Arrow = tuple[pos:Pos,kind:Block] # 設置されている方向のやつ
proc getArrows(mat:var seq[seq[Block]]): seq[Arrow] =
  result = @[]
  for x in 0..<mat.len:
    for y in 0..<mat[x].len:
      let k = mat[x][y]
      if k in arrow4: result.add(((x,y),k))
proc printAnswer(mat:var seq[seq[Block]]) =
  let arrows = mat.getArrows()
  echo arrows.len
  for p in arrows:
    echo p.pos.y," ",p.pos.x," ",p.kind
let n = scan() # 40x40
proc `+`(a,b:Pos):Pos =
  ((((a.x+b.x) mod n) + n) mod n,
   (((a.y+b.y) mod n) + n) mod n)
proc `-`(a:Pos):Pos = (-a.x,-a.y)
proc len(a:Pos):int = a.x.abs + a.y.abs
proc sub(a,b:Pos):Pos = (a.x - b.x,a.y - b.y)
proc `[]`[T](m:var seq[seq[T]],a:Pos): T = m[a.x][a.y]
proc `[]=`[T](m:var seq[seq[T]],a:Pos,v:T) = m[a.x][a.y] = v
let m = scan() # 100
let b = scan() # 300
let goal = scanPos()
let robots = newSeqWith(m,scanRobot())
let blocklist = newSeqWith(b,scanPos())
proc solve(bfsIsQueue:bool,perm:seq[int]):tuple[mat:seq[seq[Block]],score:int] =
  var mat = newSeqWith(n,newSeqWith(n,Empty)) # 床
  var initRobMat = newSeqWith(n,newSeqWith(n,Empty)) # ロボットの初期位置
  block: # make mat
    mat[goal] = BGoal
    for b in blocklist:
      mat[b] = BBlock
    for r in robots:
      initRobMat[r.pos] = r.dir.fromDir()
  # とりあえず正解を置く
  type PosKindDist = tuple[pos:Pos,kind:Block,dist:int]
  proc goalLength(x:PosKindDist) : int = (goal.sub x.pos).len
  template bfs(q) =
    for i in 0..<4:
      let d = dp4[perm[i]]
      var next = goal + d
      while mat[next] == Empty:
        q.add((next,(-d).fromDir,0))
        next = next + d
    while q.len > 0:
      let (now,kind,dist) = q.pop()
      if mat[now] != Empty: continue
      mat[now] = kind
      for i in 0..<4:
        let d = dp4[perm[i]]
        var next = now + d
        while mat[next] == Empty:
          q.add((next,(-d).fromDir,dist+1))
          next = next + d
  # 各ロボットが通る道だけ残す
  proc simplify() : seq[Robot]=
    var route = newSeqWith(n,newSeqWith(n,false))
    result = @[]
    for r in robots:
      var pos = r.pos
      var dir = r.dir
      # ゴール不可能なロボット
      if mat[pos] == Empty: continue
      result.add r
      # ゴールまで
      while mat[pos] != BGoal:
        let matDir = mat[pos].toDir
        if matDir != dir:
          route[pos] = true
        pos = pos + matDir
        dir = matDir
    for x in 0..<n:
      for y in 0..<n:
        let p : Pos = (x,y)
        if route[p]: continue
        if mat[p] in arrow4:
          mat[p] = Empty
  # 消しても上手く行く道だけ残す
  proc reduce(okRobots:seq[Robot]) =
    var initialArrows = mat.getArrows()
    while true:
      var validArrows = newSeq[Arrow]()
      for arrow in initialArrows:
        let oldArrow = mat[arrow.pos]
        mat[arrow.pos] = Empty
        # 閉路検索してもいいが,ダルいので500ターンとかで
        proc isNeed():bool =
          for r in okRobots:
            var pos = r.pos
            var dir = r.dir
            var turn = 0
            while mat[pos] != BGoal:
              if mat[pos] == BBlock:
                return true
              if turn > 500:
                return true
              if mat[pos] != Empty:
                dir = mat[pos].toDir
              pos = pos + dir
              turn += 1
          return false
        if isNeed():
          mat[arrow.pos] = oldArrow
          validArrows.add arrow
      if initialArrows.len == validArrows.len:
        break
      initialArrows = validArrows
  if bfsIsQueue:
    var q = initQueue[PosKindDist]()
    q.bfs()
  else:
    const kindMin = min([BL.int,BR.int,BU.int,BD.int])
    var q = newPriorityQueue[PosKindDist](
      proc(x,y:PosKindDist): int =
        if x.dist != y.dist: return x.dist - y.dist
        let xd = x.kind.toDir()
        let yd = y.kind.toDir()
        if xd != yd :
          let xk = x.kind.int - kindMin
          let yk = y.kind.int - kindMin
          return perm[xk] - perm[yk]
        return x.goalLength() - y.goalLength()
    )
    q.bfs()
  proc calcScore(okRobots:seq[Robot]) : int =
    var route = newSeqWith(n,newSeqWith(n,false))
    for r in okRobots:
      var pos = r.pos
      var dir = r.dir
      while mat[pos] != BGoal:
        route[pos] = true
        if mat[pos] != Empty:
          dir = mat[pos].toDir
        pos = pos + dir
    result = 1
    for x in 0..<n:
      for y in 0..<n:
        if route[x][y]: result += 1
    return result + 1000 * okRobots.len() - 10 * mat.getArrows().len()
  let okRobots = simplify()
  okRobots.reduce()
  let score = okRobots.calcScore()
  return (mat,score)

var mat = newSeqWith(1,newSeqWith(1,Empty))
var score = 0
var perm = toSeq(0..3)
while true:
  for isQueue in [false,true]:
    var (tmpMat,tmpScore) = solve(isQueue,perm)
    if tmpScore > score:
      score = tmpScore
      mat = tmpMat
  if not perm.nextPermutation(): break
mat.printAnswer()
