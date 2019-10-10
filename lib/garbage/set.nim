# https://github.com/nim-lang/Nim/issues/12184
type CSet* {.importcpp: "std::set", header: "<set>".} [T] = object
type CSetIter* {.importcpp: "std::set<'0>::iterator", header: "<set>".} [T] = object
proc cInitSet(T: typedesc): CSet[T] {.importcpp: "std::set<'*1>()", nodecl.}
proc initSet*[T](): CSet[T] = cInitSet(T)
proc erase*[T](self: var CSet[T],x:CSetIter[T]) {.importcpp: "#.erase(@)", nodecl.}
proc find*[T](self: var CSet[T],x:T): CSetIter[T] {.importcpp: "#.find(#)", nodecl.}
proc count*[T](self: var CSet[T],x:T): int {.importcpp: "#.count(#)", nodecl.}
proc lower_bound*[T](self: var CSet[T],x:T): CSetIter[T] {.importcpp: "#.lower_bound(#)", nodecl.}
proc upper_bound*[T](self: var CSet[T],x:T): CSetIter[T] {.importcpp: "#.upper_bound(#)", nodecl.}
proc begin*[T](self:var CSet[T]):CSetIter[T]{.importcpp: "#.begin()", nodecl.}
proc `end`*[T](self:var CSet[T]):CSetIter[T]{.importcpp: "#.end()", nodecl.}
proc `*`*[T](self: CSetIter[T]):T{.importcpp: "*#", nodecl.}
proc `++`*[T](self:CSetIter[T]){.importcpp: "++#", nodecl.}
proc `--`*[T](self:CSetIter[T]){.importcpp: "--#", nodecl.}
proc `==`*[T](x,y:CSetIter[T]):bool{.importcpp: "(#==#)", nodecl.}
proc insert*[T](self: var CSet[T],x:T) {.importcpp: "#.insert(@)", nodecl.}
proc empty*[T](self: var CSet[T]):bool {.importcpp: "#.empty()", nodecl.}
proc size*[T](self: var CSet[T]):int {.importcpp: "#.size()", nodecl.}
proc clear*[T](self:var CSet[T]) {.importcpp: "#.clear()", nodecl.}
proc erase*[T](self: var CSet[T],x:T) {.importcpp: "#.erase(@)", nodecl.}
proc `==`*[T](x,y:var CSet[T]):bool{.importcpp: "(#==#)", nodecl.}
import sequtils # nim alias
proc initStdSet*[T](): CSet[T] = cInitSet(T)
proc add*[T](self: var CSet[T],x:T) = self.insert(x)
proc len*[T](self: var CSet[T]):int = self.size()
proc min*[T](self: var CSet[T]):T = *self.begin()
proc max*[T](self: var CSet[T]):T = (var e = self.`end`();--e; *e)
proc contains*[T](self:var CSet[T],x:T): bool{.inline.} = not (self.find(x) == self.`end`())
iterator items*[T](self: var CSet[T]) : T =
  var (a,b) = (self.begin(),self.`end`())
  while a != b : yield *a; ++a
iterator `>`*[T](self: var CSet[T],x:T) : T =
  var (a,b) = (self.upper_bound(x),self.`end`())
  while a != b : yield *a; ++a
iterator `>=`*[T](self: var CSet[T],x:T) : T =
  var (a,b) = (self.lower_bound(x),self.`end`())
  while a != b : yield *a; ++a
iterator `<=`*[T](self: var CSet[T],x:T) : T =
  # 重複要素を個数分列挙する必要があるので upper_bound
  var (a,b) = (self.lower_bound(x),self.`begin`())
  if a != self.`end`():
    if *a <= x : yield *a
    if a != b : # 0番だった
      --a
      while a != b :
        yield *a
        --a
      if *a <= x : yield *a
iterator `<`*[T](self: var CSet[T],x:T) : T =
  var (a,b) = (self.lower_bound(x),self.`begin`())
  if a != self.`end`():
    if *a < x : yield *a
    if a != b : # 0番だった
      --a
      while a != b :
        yield *a
        --a
      if *a < x : yield *a
iterator getRange*[T](self: var CSet[T],slice:Slice[T]) : T =
  for x in self >= slice.a:
    if x > slice.b : break
    yield x
proc toSet*[T](arr:seq[T]): CSet[T] = (result = initSet[T]();for a in arr: result.add(a))
proc fromSet*[T](self: var CSet[T]):seq[T] = self.mapIt(it)
proc `$`*[T](self: CSet[T]): string = $self.mapIt(it)

when isMainModule:
  import unittest,sequtils
  test "C++ set":
    var s = @[3,1,4,1,5,9,2,6,5,3,5].toSet()
    # echo 1 in s
    check: 8 notin s
    check: s.min() == 1
    check: s.max() == 9
    check: s.len == 7
    check: s.fromSet() == @[1, 2, 3, 4, 5, 6, 9]
    check: toSeq(s > 4) == @[5, 6, 9]
    check: toSeq(s >= 4) == @[4, 5, 6, 9]
    check: toSeq(s < 4) == @[3, 2, 1]
    check: toSeq(s <= 4) == @[4, 3, 2, 1]
    check: toSeq(s.getRange(2..6)) == @[2,3,4,5,6]
    s.erase(s.max())
    check: s.max() == 6
    for _ in 0..<10: s.erase(1)
    check: s.min() == 2
    check: s == s
    # string key will be fail...
    # var ss = initSet[cstring]()
    # ss.add "ab".cstring
    # check: "ab".cstring in ss
    # check: "aba".cstring notin ss
