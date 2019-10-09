# 赤黒木. custom-compareや特殊な木の構築が必要でなければこれで良い.
type CMultiSetObj* {.importcpp: "std::multiset", header: "<set>".} [T] = object
type CMultiSetObjIter* {.importcpp: "std::multiset<'0>::iterator", header: "<set>".} [T] = object
proc cInitMultiSet(T: typedesc): CMultiSetObj[T] {.importcpp: "std::multiset<'*1>()", nodecl.}
proc initMultiSetObj*[T](): CMultiSetObj[T] = cInitMultiSet(T)
proc insert*[T](self: CMultiSetObj[T],x:T) {.importcpp: "#.insert(@)", nodecl.}
proc empty*[T](self:CMultiSetObj[T]):bool {.importcpp: "#.empty()", nodecl.}
proc size*[T](self:CMultiSetObj[T]):int {.importcpp: "#.size()", nodecl.}
proc clear*[T](self:CMultiSetObj[T]) {.importcpp: "#.clear()", nodecl.}
proc erase*[T](self:CMultiSetObj[T],x:T) {.importcpp: "#.erase(@)", nodecl.}
proc erase*[T](self:CMultiSetObj[T],x:CMultiSetObjIter[T]) {.importcpp: "#.erase(@)", nodecl.}
proc find*[T](self:CMultiSetObj[T],x:T): CMultiSetObjIter[T] {.importcpp: "#.find(#)", nodecl.}
proc lower_bound*[T](self:CMultiSetObj[T],x:T): CMultiSetObjIter[T] {.importcpp: "#.lower_bound(#)", nodecl.}
proc upper_bound*[T](self:CMultiSetObj[T],x:T): CMultiSetObjIter[T] {.importcpp: "#.upper_bound(#)", nodecl.}
proc begin*[T](self:CMultiSetObj[T]):CMultiSetObjIter[T]{.importcpp: "#.begin()", nodecl.}
proc `end`*[T](self:CMultiSetObj[T]):CMultiSetObjIter[T]{.importcpp: "#.end()", nodecl.}
proc `*`*[T](self: CMultiSetObjIter[T]):T{.importcpp: "*#", nodecl.}
proc `++`*[T](self: CMultiSetObjIter[T]){.importcpp: "++#", nodecl.}
proc `--`*[T](self: CMultiSetObjIter[T]){.importcpp: "--#", nodecl.}
# https://github.com/nim-lang/Nim/issues/12184
proc `==`*[T](x,y: CMultiSetObjIter[T]):bool{.importcpp: "(#==#)", nodecl.}
proc `==`*[T](x,y: CMultiSetObj[T]):bool{.importcpp: "(#==#)", nodecl.}
# Nim で使うためには ref にしておかないとコピーが走って死ぬ
type CMultiSet[T] = ref object
  impl*:CMultiSetObj[T]
import sequtils
proc initMultiSet*[T](): CMultiSet[T] =
  new(result)
  result.impl = initMultiSetObj[T]()
proc iniStdtMultiSet*[T](): CMultiSet[T] = initMultiSet[T]()
proc add*[T](self:CMultiSet[T],x:T) = self.impl.insert(x)
proc erase*[T](self:CMultiSet[T],x:T) = self.impl.erase(x)
proc len*[T](self:CMultiSet[T]):int = self.impl.size()
proc min*[T](self:CMultiSet[T]):T = *self.impl.begin()
proc max*[T](self:CMultiSet[T]):T = (var e = self.impl.`end`();--e; *e)
proc contains*[T](self:CMultiSet[T],x:T):bool = self.impl.find(x) != self.impl.`end`()
iterator items*[T](self:CMultiSet[T]) : T =
  var (a,b) = (self.impl.begin(),self.impl.`end`())
  while a != b : yield *a; ++a
iterator `>`*[T](self:CMultiSet[T],x:T) : T =
  var (a,b) = (self.impl.upper_bound(x),self.impl.`end`())
  while a != b :
    yield *a ;++a
iterator `>=`*[T](self:CMultiSet[T],x:T) : T =
  var (a,b) = (self.impl.lower_bound(x),self.impl.`end`())
  while a != b :
    yield *a; ++a
iterator `<=`*[T](self:CMultiSet[T],x:T) : T =
  # 重複要素を個数分列挙する必要があるので upper_bound
  var  (a,b) = (self.impl.upper_bound(x),self.impl.`begin`())
  if a != self.impl.`end`():
    if *a <= x : yield *a
    if a != b : # 0番だった
      --a
      while a != b :
        yield *a
        --a
      if *a <= x : yield *a
iterator `<`*[T](self:CMultiSet[T],x:T) : T =
  var (a,b) = (self.impl.lower_bound(x),self.impl.`begin`())
  if a != self.impl.`end`():
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
proc toMultiSet*[T](arr:seq[T]): CMultiSet[T] =
  result = initMultiSet[T]()

  for a in arr: result.add(a)
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
