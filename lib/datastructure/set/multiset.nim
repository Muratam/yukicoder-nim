# 赤黒木. custom-compareや特殊な木の構築が必要でなければこれで良い.
type CMultiSet* {.importcpp: "std::multiset", header: "<set>".} [T] = object
type CMultiSetIter* {.importcpp: "std::multiset<'0>::iterator", header: "<set>".} [T] = object
proc cInitMultiSet(T: typedesc): CMultiSet[T] {.importcpp: "std::multiset<'*1>()", nodecl.}
proc initMultiSet*[T](): CMultiSet[T] = cInitMultiSet(T)
proc insert*[T](self: var CMultiSet[T],x:T) {.importcpp: "#.insert(@)", nodecl.}
proc empty*[T](self: CMultiSet[T]):bool {.importcpp: "#.empty()", nodecl.}
proc size*[T](self: CMultiSet[T]):int {.importcpp: "#.size()", nodecl.}
proc clear*[T](self:var CMultiSet[T]) {.importcpp: "#.clear()", nodecl.}
proc erase*[T](self: var CMultiSet[T],x:T) {.importcpp: "#.erase(@)", nodecl.}
proc erase*[T](self: var CMultiSet[T],x:CMultiSetIter[T]) {.importcpp: "#.erase(@)", nodecl.}
proc find*[T](self: CMultiSet[T],x:T): CMultiSetIter[T] {.importcpp: "#.find(#)", nodecl.}
proc lower_bound*[T](self: CMultiSet[T],x:T): CMultiSetIter[T] {.importcpp: "#.lower_bound(#)", nodecl.}
proc upper_bound*[T](self: CMultiSet[T],x:T): CMultiSetIter[T] {.importcpp: "#.upper_bound(#)", nodecl.}
proc begin*[T](self:CMultiSet[T]):CMultiSetIter[T]{.importcpp: "#.begin()", nodecl.}
proc `end`*[T](self:CMultiSet[T]):CMultiSetIter[T]{.importcpp: "#.end()", nodecl.}
proc `*`*[T](self: CMultiSetIter[T]):T{.importcpp: "*#", nodecl.}
proc `++`*[T](self:var CMultiSetIter[T]){.importcpp: "++#", nodecl.}
proc `--`*[T](self:var CMultiSetIter[T]){.importcpp: "--#", nodecl.}
# https://github.com/nim-lang/Nim/issues/12184
proc `==`*[T](x,y:CMultiSetIter[T]):bool{.importcpp: "(#==#)", nodecl.}
proc `==`*[T](x,y:CMultiSet[T]):bool{.importcpp: "(#==#)", nodecl.}
# nim alias
import sequtils
proc add*[T](self:var CMultiSet[T],x:T) = self.insert(x)
proc len*[T](self:CMultiSet[T]):int = self.size()
proc min*[T](self:CMultiSet[T]):T = *self.begin()
proc max*[T](self:CMultiSet[T]):T = (var e = self.`end`();--e; *e)
proc contains*[T](self:CMultiSet[T],x:T):bool = self.find(x) != self.`end`()
iterator items*[T](self:CMultiSet[T]) : T =
  var (a,b) = (self.begin(),self.`end`())
  while a != b : yield *a; ++a
iterator `>`*[T](self:CMultiSet[T],x:T) : T =
  var (a,b) = (self.upper_bound(x),self.`end`())
  while a != b :
    yield *a ;++a
iterator `>=`*[T](self:CMultiSet[T],x:T) : T =
  var (a,b) = (self.lower_bound(x),self.`end`())
  while a != b :
    yield *a; ++a
iterator `<=`*[T](self:CMultiSet[T],x:T) : T =
  # 重複要素を個数分列挙する必要があるので upper_bound
  var (a,b) = (self.upper_bound(x),self.`begin`())
  if a != self.`end`():
    if *a <= x : yield *a
    if a != b : # 0番だった
      --a
      while a != b :
        yield *a
        --a
      if *a <= x : yield *a
iterator `<`*[T](self:CMultiSet[T],x:T) : T =
  var (a,b) = (self.lower_bound(x),self.`begin`())
  if a != self.`end`():
    if *a < x : yield *a
    if a != b : # 0番だった
      --a
      while a != b :
        yield *a
        --a
      if *a < x : yield *a
iterator getRange*[T](self:CMultiSet[T],slice:Slice[T]) : T =
  for x in self >= slice.a:
    if x > slice.b : break
    yield x

proc toMultiSet*[T](arr:seq[T]): CMultiSet[T] = (result = initMultiSet[T]();for a in arr: result.add(a))
proc fromMultiSet*[T](self:CMultiSet[T]):seq[T] = self.mapIt(it)
proc `$`*[T](self:CMultiSet[T]): string = $self.mapIt(it)


when isMainModule:
  import unittest,sequtils
  # 速い. 1e6の追加でも200ms程度.
  test "C++ multi set":
    var s = @[3,1,4,1,5,9,2,6,5,3,5].toMultiSet()
    check: 8 notin s
    check: s.min() == 1
    check: s.max() == 9
    check: s.len == 11
    check: s.fromMultiSet() == @[1, 1, 2, 3, 3, 4, 5, 5, 5, 6, 9]
    check: toSeq(s > 4) == @[5, 5, 5, 6, 9]
    check: toSeq(s >= 5) == @[5, 5, 5, 6, 9]
    check: toSeq(s <= 5) == @[5, 5, 5, 4, 3, 3, 2, 1, 1]
    check: toSeq(s < 5) == @[4, 3, 3, 2, 1, 1]
    check: toSeq(s.getRange(3..5)) == @[3, 3, 4, 5, 5, 5]
    s.erase(s.max())
    check: s.max() == 6
    for _ in 0..<10: s.erase(1)
    check: s.min() == 2
    check: s == s
