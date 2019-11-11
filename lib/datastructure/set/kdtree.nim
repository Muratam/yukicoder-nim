# http://www.prefield.com/algorithm/geometry/KDTree2D.html
# 追加・最近傍探索: O(log N)
# 削除は未実装
type
  Pos[T] = tuple[x,y:T]
  KDNode2D[T] = ref object
    pos: Pos[T]
    left,right: KDNode2D[T]
  KDTree2D[T] = ref object
    root: KDNode2D[T]
    size: int
proc distance[T](a,b:Pos[T]): T =
  return abs(a.x - b.x) + abs(a.y - b.y)
proc newKDNode2D[T](pos:Pos[T]):KDNode2D[T] =
  new(result)
  result.pos = pos
proc newKDTree2D[T]():KDTree2D[T] = new(result)
proc add[T](self:KDNode2D[T],isX:bool,pos:Pos[T]):KDNode2D[T] =
  if self == nil:
    return newKDNode2D(pos)
  if (isX and pos.x < self.pos.x) or
     (not isX and pos.y < self.pos.y):
    self.left = self.left.add(not isX,pos)
  else:
    self.right = self.right.add(not isX,pos)
  return self
proc findNearest[T](self:KDNode2D[T],isX:bool,pos:Pos[T],nowDist:T): tuple[pos:Pos[T],dist:T] =
  if self == nil: return ((-1.T,-1.T),1e12.T)
  let dist = distance(self.pos,pos)
  var resDist = nowDist
  var resPos = (0.T,0.T)
  if dist < resDist:
    resDist = dist
    resPos = self.pos
  let isLeft =
     (isX and pos.x < self.pos.x) or
     (not isX and pos.y < self.pos.y)
  proc update(isLeft:bool) =
    let found =
      if isLeft : self.left.findNearest(not isX,pos,resDist)
      else: self.right.findNearest(not isX,pos,resDist)
    if found.dist < resDist:
      resPos = found.pos
      resDist = found.dist
  update(isLeft)
  if (isX and abs(pos.x - self.pos.x) <= resDist) or
    (not isX and abs(pos.y - self.pos.y) <= resDist):
    update(not isLeft)
  return (resPos,resDist)
proc add[T](self:KDTree2D[T],pos:Pos[T]) =
  self.root = self.root.add(false,pos)
  self.size += 1
proc len[T](self:KDTree2D[T]):int = self.size
proc findNearest[T](self:KDTree2D[T],pos:Pos[T]): tuple[pos:Pos[T],dist:T] =
  self.root.findNearest(false,pos,1e12.T)

when isMainModule:
  import unittest
  import times
  import "../../mathlib/random"
  template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
  if false:
    let n = 1e6.int
    stopwatch:
      var kdTree = newKDTree2D[int]()
      for i in 0..<n: kdTree.add((randomBit(20),randomBit(20)))
    for i in 0..<10:
      let pos = (randomBit(20),randomBit(20))
      echo pos,kdTree.findNearest(pos)
  test "KDTree":
    var kdTree = newKDTree2D[int]()
    kdTree.add((0,10))
    kdTree.add((1000,50))
    kdTree.add((1000,1050))
    check: kdTree.len == 3
    check: kdTree.findNearest((900,800)) == ((1000,1050),350)
