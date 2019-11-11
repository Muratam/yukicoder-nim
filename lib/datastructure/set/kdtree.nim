# http://www.prefield.com/algorithm/geometry/KDTree2D.html
# https://topcoder.g.hatena.ne.jp/spaghetti_source/20120908/1347059626
# 追加・最近傍探索: O(log N)
# 削除は再構築しないので徐々に遅くなっていく.
# => N回find/eraseしたら根から(平衡なKD木を)再構築すると多分 O(logN)になると思います.
type
  Pos*[T] = tuple[x,y:T]
  KDNode2D[T] = ref object
    pos: Pos[T]
    left,right: KDNode2D[T]
    sameCount: int
  KDTree2D*[T] = ref object
    root: KDNode2D[T]
    size: int
proc newKDNode2D[T](pos:Pos[T]):KDNode2D[T] =
  new(result)
  result.pos = pos
  result.sameCount = 1
proc add[T](self:KDNode2D[T],isX:bool,pos:Pos[T]):KDNode2D[T] =
  if self == nil:
    return newKDNode2D(pos)
  if pos == self.pos:
    self.sameCount += 1
    return self
  if (isX and pos.x < self.pos.x) or
     (not isX and pos.y < self.pos.y):
    self.left = self.left.add(not isX,pos)
  else:
    self.right = self.right.add(not isX,pos)
  return self
proc erase[T](self:KDNode2D[T],isX:bool,pos:Pos[T]) : bool {.discardable.}=
  if self == nil: return false
  if self.pos == pos:
    if self.sameCount > 0:
      self.sameCount -= 1
      return true
    return false
  if (isX and pos.x < self.pos.x) or
     (not isX and pos.y < self.pos.y):
    return self.left.erase(not isX,pos)
  else:
    return self.right.erase(not isX,pos)
proc contains[T](self:KDNode2D[T],isX:bool,pos:Pos[T]) : bool =
  if self == nil: return false
  if self.pos == pos:
    return self.sameCount > 0
  if (isX and pos.x < self.pos.x) or
     (not isX and pos.y < self.pos.y):
    return self.left.contains(not isX,pos)
  else:
    return self.right.contains(not isX,pos)
proc findNearest[T](self:KDNode2D[T],distanceFunc : proc (a,b:Pos[T]): T,isX:bool,pos:Pos[T],nowDist:T): tuple[pos:Pos[T],dist:T] =
  if self == nil: return (pos,nowDist)
  var resDist = nowDist
  var resPos : Pos[T]
  if self.sameCount > 0:
    let dist = distanceFunc(self.pos,pos)
    if dist < resDist:
      resDist = dist
      resPos = self.pos
  let isLeft =
     (isX and pos.x < self.pos.x) or
     (not isX and pos.y < self.pos.y)
  proc update(isLeft:bool) =
    let found =
      if isLeft : self.left.findNearest(distanceFunc,not isX,pos,resDist)
      else: self.right.findNearest(distanceFunc,not isX,pos,resDist)
    if found.dist < resDist:
      resPos = found.pos
      resDist = found.dist
  update(isLeft)
  if (isX and distanceFunc(pos,(self.pos.x,pos.y)) < resDist) or
    (not isX and distanceFunc(pos,(pos.x,self.pos.y)) < resDist):
    update(not isLeft)
  return (resPos,resDist)
proc newKDTree2D*[T]():KDTree2D[T] = new(result)
proc len*[T](self:KDTree2D[T]):int = self.size
proc add*[T](self:KDTree2D[T],pos:Pos[T]) =
  self.root = self.root.add(false,pos)
  self.size += 1
proc erase*[T](self:KDTree2D[T],pos:Pos[T]): bool {.discardable.} =
  result = self.root.erase(false,pos)
  if result: self.size -= 1
proc contains*[T](self:KDTree2D[T],pos:Pos[T]): bool =
  self.root.contains(false,pos)
proc findNearest*[T](self:KDTree2D[T],distanceFunc : proc (a,b:Pos[T]):T,pos:Pos[T]): tuple[pos:Pos[T],dist:T] =
  self.root.findNearest(distanceFunc,false,pos,1e12.T)
iterator items*[T](self:KDTree2D[T]) : Pos[T] =
  var nodes = @[self.root]
  while nodes.len > 0:
    let now = nodes.pop()
    if now == nil: continue
    for i in 0..<now.sameCount: yield now.pos
    if now.left != nil : nodes.add(now.left)
    if now.right != nil: nodes.add(now.right)
proc sqEuclidDistance*[T](a,b:Pos[T]): T = # 円
  (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y)
proc manhattanDistance*[T](a,b:Pos[T]): T = # ひし形
  abs(a.x - b.x) + abs(a.y - b.y)
proc chebyshevDistance*[T](a,b:Pos[T]): T = # 四角
  abs(a.x - b.x).max(abs(a.y - b.y))

import algorithm
# O(N(logN)^2)
proc buildKDNode[T](poses:seq[Pos[T]],isX:bool):KDNode2D[T] =
  if poses.len == 0 : return nil
  let poses =
    if isX: poses.sortedByIt(it.x)
    else: poses.sortedByIt(it.y)
  new(result)
  let mid = poses.len div 2
  var midP = mid
  var midM = mid
  result.pos = poses[mid]
  result.sameCount = 1
  for i in (mid+1)..<poses.len:
    if poses[i] != poses[mid]: break
    result.sameCount += 1
    midP = i
  for i in (mid-1).countDown(0):
    if poses[i] != poses[mid]: break
    result.sameCount += 1
    midM = i
  result.left = poses[0..<midM].buildKDNode(not isX)
  result.right = poses[midP+1..^1].buildKDNode(not isX)
proc buildKDTree2D*[T](poses:seq[Pos[T]]):KDTree2D[T] =
  new(result)
  result.size = poses.len
  result.root = poses.buildKDNode(false)


when isMainModule:
  import unittest
  import times,sequtils
  import "../../mathlib/random"
  template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
  if false:
    let n = 1e6.int
    stopwatch:
      var kdTree = newKDTree2D[int]()
      for i in 0..<n: kdTree.add((randomBit(20),randomBit(20)))
    var sumD = 0
    stopwatch:
      for i in 0..<n:
        let pos = (randomBit(20),randomBit(20))
        sumD += kdTree.findNearest(chebyshevDistance[int],pos).dist
  test "KDTree":
    var kdTree = newKDTree2D[int]()
    kdTree.add((0,10))
    kdTree.add((1000,50))
    kdTree.add((1000,1050))
    check: kdTree.len == 3
    check: kdTree.findNearest(manhattanDistance[int],(900,800)) == ((1000,1050),350)
    check: not kdTree.erase((-1,-1))
    check: kdTree.len == 3
    check: kdTree.erase((1000,1050))
    check: kdTree.len == 2
    check: kdTree.findNearest(manhattanDistance[int],(900,800)) == ((1000,50),850)
    check: (0,10) in kdTree
    check: (10,10) notin kdTree
    kdTree.add((0,10))
    check: kdTree.len == 3
    # echo toSeq(kdTree)
