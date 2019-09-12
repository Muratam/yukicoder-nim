type CPriorityQueue* {.importcpp: "std::priority_queue", header: "<queue>".} [T] = object
proc cInitPriorityQueue(T: typedesc): CPriorityQueue[T] {.importcpp: "std::priority_queue<'*1>()", nodecl.}
proc initPriorityQueue*[T](): CPriorityQueue[T] = cInitPriorityQueue(T)
proc size*[T](self: CPriorityQueue[T]):int {.importcpp: "#.size()", nodecl.}
proc top*[T](self: CPriorityQueue[T]): T {.importcpp: "#.top()", nodecl.}
proc empty*[T](self: CPriorityQueue[T]):bool {.importcpp: "#.empty()", nodecl.}
proc push*[T](self:var CPriorityQueue[T],x:T) {.importcpp: "#.push(@)", nodecl.}
proc popImpl[T](self:var CPriorityQueue[T]) {.importcpp: "#.pop()", nodecl.}
proc pop*[T](self:var CPriorityQueue[T]) : T = (result = self.top();self.popImpl())
# https://github.com/nim-lang/Nim/issues/12184
proc `==`*[T](x,y:CPriorityQueue[T]):bool{.importcpp: "(#==#)", nodecl.}
import sequtils # for nim alias
proc len*[T](self:CPriorityQueue[T]):int = self.size()
proc add*[T](self:var CPriorityQueue[T],x:T) = self.push(x)
iterator items*[T](self:CPriorityQueue[T]): T = (var cp = self;while not cp.empty(): yield cp.pop())
proc toSeq*[T](self:CPriorityQueue[T]):seq[T] = self.mapIt(it)
proc `$`*[T](self:CPriorityQueue[T]): string = $self.toSeq()
when isMainModule:
  import unittest
  test "C++ priority queue":
    var pq = initPriorityQueue[int]()
    pq.add(11)
    pq.add(4)
    pq.add(12)
    var pq2 = pq
    check: pq.len == 3
    check: pq.pop() == 12
    check: not pq.empty()
    check: pq.pop() == 11
    check: not pq.empty()
    check: pq.pop() == 4
    check: pq.empty()
    check: not pq2.empty()
    check: pq2.pop() == 12
    check: not pq2.empty()
