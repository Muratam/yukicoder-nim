
type
  KDNode[T] = ref object
    pos: T
    left,right: KDNode
  KDTree[T] = ref object
    root: KDNode[T]
    distance: proc(pos,top,bottom:T): float
proc newKDNode[T](pos:T) : KDNode[T] =
  new(result)
  result.pos = pos
proc newKDTree[T](distance:proc(pos,top,bottom:T): float) :KDTree[T] =
  new(result)
  result.distance = distance
# proc add[T](self:KDTree[T],pos:T,depth:int = 0) =
# proc nearer(self:KDTree[T],pos:T,)
