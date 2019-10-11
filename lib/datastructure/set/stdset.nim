# 赤黒木. 通常用途ならこれでよい.
# https://github.com/nim-lang/Nim/issues/12184
import sequtils
type CMultiSet* {.importcpp: "std::multiset", header: "<set>".} [T] = object
type CMultiSetIter* {.importcpp: "std::multiset<'0>::iterator", header: "<set>".} [T] = object
proc cInitMultiSet(T: typedesc): CMultiSet[T] {.importcpp: "std::multiset<'*1>()", nodecl.}
proc initStdMultiSet*[T](): CMultiSet[T] = cInitMultiSet(T)
proc insert*[T](self: CMultiSet[T],x:T) {.importcpp: "#.insert(@)", nodecl.}
proc empty*[T](self:CMultiSet[T]):bool {.importcpp: "#.empty()", nodecl.}
proc size*[T](self:CMultiSet[T]):int {.importcpp: "#.size()", nodecl.}
proc clear*[T](self:CMultiSet[T]) {.importcpp: "#.clear()", nodecl.}
proc erase*[T](self:CMultiSet[T],x:T) {.importcpp: "#.erase(@)", nodecl.}
proc erase*[T](self:CMultiSet[T],x:CMultiSetIter[T]) {.importcpp: "#.erase(@)", nodecl.}
proc find*[T](self:CMultiSet[T],x:T): CMultiSetIter[T] {.importcpp: "#.find(#)", nodecl.}
proc lower_bound*[T](self:CMultiSet[T],x:T): CMultiSetIter[T] {.importcpp: "#.lower_bound(#)", nodecl.}
proc upper_bound*[T](self:CMultiSet[T],x:T): CMultiSetIter[T] {.importcpp: "#.upper_bound(#)", nodecl.}
proc begin*[T](self:CMultiSet[T]):CMultiSetIter[T]{.importcpp: "#.begin()", nodecl.}
proc `end`*[T](self:CMultiSet[T]):CMultiSetIter[T]{.importcpp: "#.end()", nodecl.}
proc `*`*[T](self: CMultiSetIter[T]):T{.importcpp: "(*#)", nodecl.}
proc `++`*[T](self: CMultiSetIter[T]){.importcpp: "(++#)", nodecl.}
proc `--`*[T](self: CMultiSetIter[T]){.importcpp: "(--#)", nodecl.}
proc `==`*[T](x,y: CMultiSetIter[T]):bool{.importcpp: "(#==#)", nodecl.}
proc `==`*[T](x,y: CMultiSet[T]):bool{.importcpp: "(#==#)", nodecl.}
# alias (var を付けないとコピーが走り危険なのでつけること)
proc add*[T](self:var CMultiSet[T],x:T) = self.insert(x)
proc len*[T](self:var CMultiSet[T]):int = self.size()
proc min*[T](self:var CMultiSet[T]):T = *self.begin()
proc max*[T](self:var CMultiSet[T]):T = (var e = self.`end`();--e; *e)
proc contains*[T](self:var CMultiSet[T],x:T):bool = self.find(x) != self.`end`()
proc checkNotExists*[T](self:var CMultiSet[T],x:T):bool = not (x in self)
iterator items*[T](self:var CMultiSet[T]) : T =
  var a = self.begin()
  var b = self.`end`()
  while a != b : yield *a; ++a
iterator `>`*[T](self:var CMultiSet[T],x:T) : T =
  var (a,b) = (self.upper_bound(x),self.`end`())
  while a != b :
    yield *a ;++a
iterator `>=`*[T](self:var CMultiSet[T],x:T) : T =
  var (a,b) = (self.lower_bound(x),self.`end`())
  while a != b :
    yield *a; ++a
iterator `<=`*[T](self:var CMultiSet[T],x:T) : T =
  # 重複要素を個数分列挙する必要があるので upper_bound
  var  (a,b) = (self.upper_bound(x),self.`begin`())
  if a != self.`end`():
    if *a <= x : yield *a
    if a != b : # 0番だった
      --a
      while a != b :
        yield *a
        --a
      if *a <= x : yield *a
iterator `<`*[T](self:var CMultiSet[T],x:T) : T =
  var (a,b) = (self.lower_bound(x),self.`begin`())
  if a != self.`end`():
    if *a < x : yield *a
    if a != b : # 0番だった
      --a
      while a != b :
        yield *a
        --a
      if *a < x : yield *a
iterator at*[T](self:var CMultiSet[T],slice:Slice[T]) : T =
  var (a,b) = (self.lower_bound(slice.a),self.`end`())
  while a != b:
    if *a > slice.b : break
    yield *a; ++a
proc toMultiSet*[T](arr:seq[T]): CMultiSet[T] =
  result = initStdMultiSet[T]()
  for a in arr: result.add(a)
proc fromMultiSet*[T](self:var CMultiSet[T]):seq[T] = toSeq(self.items)
proc `$`*[T](self:var CMultiSet[T]): string = $self.mapIt(it)

# Nim で使うためには ref にしておかないとコピーが走って死ぬ
  # type CMultiSet[T] = ref object
  #   impl*:CMultiSet[T]
  # import sequtils
  # proc initMultiSet*[T](): CMultiSet[T] =
  #   new(result)
  #   result.impl = initStdMultiSet[T]()
  # proc initStdMultiSet*[T](): CMultiSet[T] = initMultiSet[T]()
  # proc add*[T](self:CMultiSet[T],x:T) = self.insert(x)
  # proc erase*[T](self:CMultiSet[T],x:T) = self.erase(x)
  # proc len*[T](self:CMultiSet[T]):int = self.size()
  # proc min*[T](self:CMultiSet[T]):T = *self.begin()
  # proc max*[T](self:CMultiSet[T]):T = (var e = self.`end`();--e; *e)
  # proc contains*[T](self:CMultiSet[T],x:T):bool = self.find(x) != self.`end`()
  # iterator items*[T](self:CMultiSet[T]) : T =
  #   var (a,b) = (self.begin(),self.`end`())
  #   while a != b : yield *a; ++a
  # iterator `>`*[T](self:CMultiSet[T],x:T) : T =
  #   var (a,b) = (self.upper_bound(x),self.`end`())
  #   while a != b :
  #     yield *a ;++a
  # iterator `>=`*[T](self:CMultiSet[T],x:T) : T =
  #   var (a,b) = (self.lower_bound(x),self.`end`())
  #   while a != b :
  #     yield *a; ++a
  # iterator `<=`*[T](self:CMultiSet[T],x:T) : T =
  #   # 重複要素を個数分列挙する必要があるので upper_bound
  #   var  (a,b) = (self.upper_bound(x),self.`begin`())
  #   if a != self.`end`():
  #     if *a <= x : yield *a
  #     if a != b : # 0番だった
  #       --a
  #       while a != b :
  #         yield *a
  #         --a
  #       if *a <= x : yield *a
  # iterator `<`*[T](self:CMultiSet[T],x:T) : T =
  #   var (a,b) = (self.lower_bound(x),self.`begin`())
  #   if a != self.`end`():
  #     if *a < x : yield *a
  #     if a != b : # 0番だった
  #       --a
  #       while a != b :
  #         yield *a
  #         --a
  #       if *a < x : yield *a
  # iterator getRange*[T](self:CMultiSet[T],slice:Slice[T]) : T =
  #   for x in self >= slice.a:
  #     if x > slice.b : break
  #     yield x
  # proc toMultiSet*[T](arr:seq[T]): CMultiSet[T] =
  #   result = initMultiSet[T]()

  #   for a in arr: result.add(a)
  # proc fromMultiSet*[T](self:CMultiSet[T]):seq[T] = self.mapIt(it)
  # proc `$`*[T](self:CMultiSet[T]): string = $self.mapIt(it)

{.checks:off.}
when isMainModule:
  import unittest,sequtils,times
  template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
  import "../../mathlib/random"
  if false: # ベンチ
    let n = 1e6.int
    var S = initStdMultiSet[int]()
    var dummy = 0
    stopwatch:
      for i in 0..<n: S.insert randomBit(30)
    echo S.len
    stopwatch:
      for i in 0..<n: dummy += S.empty().int
    echo S.len
    stopwatch:
      for i in 0..<n: dummy += S.size().int
    echo S.len
    stopwatch:
      for i in 0..<n: S.clear()
    echo S.len
    stopwatch:
      for i in 0..<n: S.add randomBit(30)
    echo S.len
    stopwatch:
      for i in 0..<n: S.erase randomBit(30)
    echo S.len
    stopwatch:
      for i in 0..<n: dummy += S.len
    echo S.len
    stopwatch:
      for i in 0..<n: dummy += S.max()
    echo S.len
    stopwatch:
      for i in 0..<n: dummy += S.min()
    echo S.len
    stopwatch:
      for i in 0..<n: dummy += (S.checkNotExists(i)).int
    echo S.len
    stopwatch:
      echo toSeq(S.items).len
    stopwatch:
      echo toSeq(S > randomBit(30)).len
    stopwatch:
      echo toSeq(S >= randomBit(30)).len
    stopwatch:
      echo toSeq(S < randomBit(30)).len
    stopwatch:
      echo toSeq(S <= randomBit(30)).len

    echo dummy
    quit 0

  test "C++ multi set":
    var s = @[3,1,4,1,5,9,2,6,5,3,5].toMultiSet()
    check: 8 notin s
    check: s.min() == 1
    check: s.max() == 9
    check: s.len == 11
    check: s.fromMultiSet() == @[1, 1, 2, 3, 3, 4, 5, 5, 5, 6, 9]
    check: toSeq(s.at(3..5)) == @[3, 3, 4, 5, 5, 5]
    check: toSeq(s > 4) == @[5, 5, 5, 6, 9]
    check: toSeq(s >= 5) == @[5, 5, 5, 6, 9]
    check: toSeq(s <= 5) == @[5, 5, 5, 4, 3, 3, 2, 1, 1]
    check: toSeq(s < 5) == @[4, 3, 3, 2, 1, 1]
    s.erase(s.max())
    check: s.max() == 6
    for _ in 0..<10: s.erase(1)
    check: s.min() == 2
    check: s == s
