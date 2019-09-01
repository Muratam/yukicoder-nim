import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord


type CPriorityQueue* {.importcpp: "std::priority_queue", header: "<queue>".} [T] = object
proc cInitPriorityQueue(T: typedesc): CPriorityQueue[T] {.importcpp: "std::priority_queue<'*1>()", nodecl.}
proc initPriorityQueue*[T](): CPriorityQueue[T] = cInitPriorityQueue(T)
proc size*[T](self: CPriorityQueue[T]):int {.importcpp: "#.size()", nodecl.}
proc top*[T](self: CPriorityQueue[T]): T {.importcpp: "#.top()", nodecl.}
proc empty*[T](self: CPriorityQueue[T]):bool {.importcpp: "#.empty()", nodecl.}
proc push*[T](self:var CPriorityQueue[T],x:T) {.importcpp: "#.push(@)", nodecl.}
proc popImpl[T](self:var CPriorityQueue[T]) {.importcpp: "#.pop()", nodecl.}
proc pop*[T](self:var CPriorityQueue[T]) : T = (result = self.top();self.popImpl())
proc `==`*[T](x,y:CPriorityQueue[T]):bool{.importcpp: "#==#", nodecl.}
import sequtils # for nim alias
proc len*[T](self:CPriorityQueue[T]):int = self.size()
proc add*[T](self:var CPriorityQueue[T],x:T) = self.push(x)
iterator items*[T](self:CPriorityQueue[T]): T = (var cp = self;while not cp.empty(): yield cp.pop())
proc toSeq*[T](self:CPriorityQueue[T]):seq[T] = self.mapIt(it)
proc `$`*[T](self:CPriorityQueue[T]): string = $self.toSeq()



let n = scan()
let m = scan()
let AB = newSeqWith(n,(a:scan(),b:scan())).sorted(proc(x,y:tuple[a,b:int]):int =
  if x.a != y.a : return x.a - y.a
  return x.b - y.b
  )
var i = 0
var ans = 0
var leftCmds = initPriorityQueue[int]()
for left in 1..m:
  while i < AB.len and AB[i].a == left:
    leftCmds.push(AB[i].b)
    i += 1
  if leftCmds.size > 0:
    ans += leftCmds.top()
    leftCmds.popImpl()

echo ans
