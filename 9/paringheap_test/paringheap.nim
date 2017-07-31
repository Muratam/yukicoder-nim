import sequtils,random
type
  NodeObj[T] = object
    head,next:ref NodeObj[T]
    key:T
  Node[T] = ref NodeObj[T]
  ParingHeap*[T] = object
    node: Node[T]
proc initNode*[T](): Node[T] = new(result)
proc initParingHeap*[T](): ParingHeap[T] = discard
proc newNode[T](key:T):Node[T] =
  new(result); result.key = key
proc merge*[T](n1,n2:var Node[T]) :Node[T] =
  if n1 == nil : return n2
  if n2 == nil : return n1
  if cmp[T](n1.key, n2.key) > 0: swap(n1,n2)
  n2.next = n1.head
  n1.head = n2
  return n1
proc mergeList[T](s:var Node[T]):Node[T] =
  var n = initNode[T]()
  while s != nil:
    var
      a = s
      b :Node[T] = nil
    s = s.next
    a.next = nil
    if s != nil:
      b = s
      s = s.next
      b.next = nil
    a = merge(a,b)
    a.next = n.next
    n.next = a
  while n.next != nil:
    var j = n.next
    n.next = n.next.next
    s = merge(j,s)
  return s
proc empty*[T](ph:ParingHeap[T]) :bool = ph.node != nil
proc top*[T](ph:ParingHeap[T]):T = ph.node.key
proc push*[T](ph:var ParingHeap[T],key:T):void =
  var n = newNode(key)
  ph.node = merge(ph.node,n)
proc pop*[T](ph:var ParingHeap[T]):T =
  result = ph.top()
  ph.node = mergeList(ph.node.head)

template itemsListImpl() {.dirty.} =
  yield L.node.key
  var it = L.node.head
  while it != nil:
    yield it.key
    it = it.next
iterator items*[T](L: ParingHeap[T]): T = itemsListImpl()


var b = initParingHeap[(int,int)]()
for i in 0..<1000:
  b.push((random(100),1))
  b.push((random(200),2))
  b.push((random(300),3))
  discard b.pop()
echo newSeqWith(2000,b.pop())
