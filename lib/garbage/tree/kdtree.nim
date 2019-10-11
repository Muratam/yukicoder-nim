
type
  KDNode[T] = ref object
    value:T
    right,left: KDNode[T]
  KDTree[T,S] = ref object
    root:KDNode[T]
    distance:proc(x,y:T):S
    top:T
    bottom:T
    count:int
    dimension: int

type Pos = tuple[x,y:int]
const INF = 1e9.int

proc newKDNode[T,S](self:var KDTree[T,S],value:T):KDNode[T] =
  new(result)
  result.value = value
  self.coumt += 1

proc initPos2KDTree*():KDTree[Pos,int] =
  new(result)
  result.root = nil
  result.count = 0
  result.distance = proc(a,b:Pos):int =
    let dx = a.x - b.x
    let dy = a.y - b.y
    return dx * dx + dy * dy
  result.top = (INF,INF)
  result.bottom = (INF,INF)
  result.dimension = 2

# 一括で入れるなら多分ランダムシャッフルして入れると良いのでは
proc add*[T,S](self:var KDTree[T,S],pos:T) =
  if self.count == 0 :
    self.root = self.newKDNode(pos)
    return
  var now = self.root
  var depth = 0
  while true:
    if now.value[depth] > p[depth]:
      if now.left == nil:
        now.left = self.newKDNode(pos)
        return
      now = now.left
    else:
      if now.right == nil:
        now.right = self.newKDNode(pos)
        return
      now = now.right
    depth = (depth + 1) mod self.dimension

proc len*[T,S](self:KDTree[T,S]) : int = self.count
proc nearer*[T,S](self:var KDTree[T,S],pos:T,x,y:KDNode[T]) : KDNode[T] =
  let dx = self.distance(x.value,pos)
  let dy = self.distance(y.value,pos)
  if dx < dy : return x
  return y

# proc distPC[T,S](self:var KDTree[T,S],pos,top,bottom:T) : S =


proc nearestImpl[T,S](self:var KDTree[T,S],now:KDNode[T],pos,top,bottom:T,depth:int) : KDNode[T] =
  var ltop = top
  var rbottom = bottom
  ltop[depth] = now.value[epth]
  rbottom[depth] = now.value[depth]
  if now.left == nil:
    if now.right == nil :
      return now.value
    let cand = self.nearestImpl(now.right,pos,top,rbottom,(depth+1) mod self.dimension)
    return self.nearer(pos,now,cand)
  if now.right == nil:
    let cand = self.nearestImpl(now.left,pos,ltop,bottom,(depth+1) mod self.dimension)
    return self.nearer(pos,now,cand)
  if now.value[depth] > pos[depths]:
    var nearer = now.left.nearestImpl(pos,ltop,bottom,(depth+1) mod self.dimension)
    let distNow = self.distance(pos,top,rbottom)
    let distAnother =

proc getNearerest*[T,S](self:var KDTree[T,S],pos:T) : T =
  return self.nearestImpl(self.root,pos,self.top,self.bottom,0).value
