# 範囲が広大で動的な場合.
# オーバーヘッドは通常のものより大きい.
type
  DinamicSegmentTreeNode[T] = ref object
    data:T
    left,right,parent:DinamicSegmentTreeNode[T]
    at:Slice[int]
  DinamicSegmentTree[T] = ref object
    root:DinamicSegmentTreeNode[T]
    unit*: T
    apply*:proc(x,y:T):T
proc newDinamicSegmentTreeNode*[T](self: DinamicSegmentTree[T],at:Slice[int]):DinamicSegmentTreeNode[T] =
  new(result)
  result.at = at
  result.data = self.unit
proc newDinamicSegmentTree*[T](at:Slice[int],apply:proc(x,y:T):T,unit:T):DinamicSegmentTree[T] =
  new(result)
  result.unit = unit
  result.apply = apply
  result.root = result.newDinamicSegmentTreeNode(at)

proc isLeaf*[T](node:DinamicSegmentTreeNode[T]) : bool =
  node.at.b - node.at.a == 0
proc isRoot*[T](node:DinamicSegmentTreeNode[T]) : bool =
  node.parent == nil
proc `[]=`*[T](self:var DinamicSegmentTree[T],i:int,val:T) =
  var now = self.root
  # 作成
  while not now.isLeaf():
    let mid = (now.at.a+now.at.b+1) shr 1
    echo(@[now.at.a,mid,now.at.b])
    if i < mid :
      if now.left == nil:
        now.left = self.newDinamicSegmentTreeNode(now.at.a..<mid)
        now.left.parent = now
      now = now.left
    else:
      if now.right == nil:
        now.right = self.newDinamicSegmentTreeNode(mid..now.at.b)
        now.right.parent = now
      now = now.right
  now.data = val
  now = now.parent
  while not now.isRoot():
    var left = self.unit
    var right = self.unit
    if now.left != nil : left = now.left.data
    if now.right != nil : right = now.right.data
    now.data = self.apply(left,right)
    now = now.parent
proc queryImpl*[T](self:DinamicSegmentTree[T],target:Slice[int],node:DinamicSegmentTreeNode[T]) : T =
  if node.at.b <= target.a or target.b <= node.at.a : return self.unit # 探索範囲外
  if target.a <= node.at.a and node.at.b <= target.b :
    return node.data
  if node.isLeaf: return node.data
  if node.left == nil: return self.queryImpl(target,node.right)
  if node.right == nil: return self.queryImpl(target,node.left)
  let vl = self.queryImpl(target,node.left)
  let vr = self.queryImpl(target,node.right)
  return self.apply(vl,vr)
proc `[]`*[T](self:DinamicSegmentTree[T],at:Slice[int]): T =
  self.queryImpl(at,self.root) # 全範囲を,根から
proc `[]`*[T](self:DinamicSegmentTree[T],i:int): T =
  self[i..i]
test "Dinamic Segment Tree":
  block: # スパース時の加算のやつ
    const EPS = 1e-6
    proc `~~`(x, y: float): bool = abs(x - y) < EPS # ≒
    var S = newDinamicSegmentTree(-50000..50000,proc(x,y:float):float=x+y,0.0)
    S[50] = 100.0.float
    S[421] = 500.0.float
    S[-50] = 20.0.float
    S[100] = 10.0.float
    echo: S[id(-10000)..10000] ~~ 630.0
    echo: S[49..<50] ~~ 0.0
    echo: S[49..50] ~~ 100.0
    echo: S[50..50] #~~ 100.0
    echo: S[50..51] #~~ 100.0
    echo: S[58..<421] ~~ 10.0
    echo: S[58..421] #~~ 510.0
