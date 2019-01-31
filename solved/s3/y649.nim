import sequtils,macros
template times*(n:int,body) = (for _ in 0..<n: body)
proc pc(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

proc printInt(a0:int) =
  template put(n:int) = pc("0123456789"[n])
  proc div10(a:int):int {.inline.} =
    const maxA = int32.high shl 4
    if a < maxA : return cast[int32]((0x1999999A * a) shr 32)
    else: return a div 10
  var A:array[18,int]
  if a0 == 0 :
    pc('0')
    return
  A[0] = a0
  var i = 0
  while true:
    A[i+1] = A[i].div10
    if A[i+1] == 0 : break
    A[i] -= A[i+1] * 10
    i += 1
  while i >= 0:
    put(A[i])
    i -= 1


template useBinaryHeap() =
  type
    BinaryHeap*[T] = object
      nodes: seq[T]
      compare: proc(x,y:T):int
      popchunk: bool
  proc newBinaryHeap*[T](compare:proc(x,y:T):int): BinaryHeap[T] =
    BinaryHeap[T](nodes:newSeq[T](),compare:compare,popchunk:false)
  proc compareNode[T](h:BinaryHeap[T],i,j:int):int = h.compare(h.nodes[i],h.nodes[j])
  proc size*[T](h:BinaryHeap[T]):int = h.nodes.len() - h.popchunk.int
  proc items*[T](h:var BinaryHeap[T]):seq[T] =
    if h.popchunk : discard h.popimpl()
    return h.nodes
  proc top*[T](h:var BinaryHeap[T]): T =
    if h.popchunk : discard h.popimpl()
    return h.nodes[0]
  proc push*[T](h:var BinaryHeap[T],node:T):void =
    if h.popchunk :
      h.nodes[0] = node
      h.shiftdown()
    else: h.pushimpl(node)
  proc pop*[T](h:var BinaryHeap[T]):T =
    if h.popchunk: discard h.popimpl()
    h.popchunk = true
    return h.nodes[0]

  proc shiftdown[T](h:var BinaryHeap[T]): void =
    h.popchunk = false
    let size = h.nodes.len()
    var i = 0
    while true :
      let L = i * 2 + 1
      let R = i * 2 + 2
      if L >= size : break
      let child = if R < size and h.compareNode(R,L) <= 0 : R else: L
      if h.compareNode(i,child) <= 0: break
      swap(h.nodes[i],h.nodes[child])
      i = child

  proc pushimpl[T](h:var BinaryHeap[T],node:T):void =
    h.nodes.add(node) #末尾に追加
    var i = h.nodes.len() - 1
    while i > 0: # 末尾から木を整形
      let parent = (i - 1) div 2
      if h.compare(h.nodes[parent],node) <= 0: break
      h.nodes[i] = h.nodes[parent]
      i = parent
    h.nodes[i] = node

  proc popimpl[T](h:var BinaryHeap[T]):T =
    result = h.nodes[0] # rootと末尾を入れ替えて木を整形
    h.nodes[0] = h.nodes[^1]
    h.nodes.setLen(h.nodes.len() - 1)
    h.shiftdown()

useBinaryHeap()

let q = scan()
let k = scan()
var less = newBinaryHeap[int](proc(x,y:int):int = -x+y)
var greater = newBinaryHeap[int](proc(x,y:int):int = -y+x)
q.times:
  if less.size() > 0 : discard less.top()
  if greater.size() > 0 : discard greater.top()
  if scan() == 1:
    let v = scan()
    if less.size() < k : less.push(v)
    else:
      if v < less.top() :
        greater.push(less.pop())
        less.push(v)
      else: greater.push(v)
  else:
    if less.size() < k : pc('-');pc('1')
    else:
      less.pop().printInt()
      if greater.size() > 0 : less.push(greater.pop())
    pc('\n')