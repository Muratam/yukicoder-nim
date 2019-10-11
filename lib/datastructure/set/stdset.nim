# 赤黒木. 通常用途ならこれでよい.
# 速いしどんなデータにも安定感があるし短いし.
# https://github.com/nim-lang/Nim/issues/12184

# ############################################################################
# std::multiset
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

# ############################################################################
# std::set
type CSet* {.importcpp: "std::set", header: "<set>".} [T] = object
type CSetIter* {.importcpp: "std::set<'0>::iterator", header: "<set>".} [T] = object
import sequtils
proc cInitSet(T: typedesc): CSet[T] {.importcpp: "std::set<'*1>()", nodecl.}
proc initStdSet*[T](): CSet[T] = cInitSet(T)
proc erase*[T](self:CSet[T],x:CSetIter[T]) {.importcpp: "#.erase(@)", nodecl.}
proc find*[T](self:CSet[T],x:T): CSetIter[T] {.importcpp: "#.find(#)", nodecl.}
proc count*[T](self:CSet[T],x:T): int {.importcpp: "#.count(#)", nodecl.}
proc lower_bound*[T](self:CSet[T],x:T): CSetIter[T] {.importcpp: "#.lower_bound(#)", nodecl.}
proc upper_bound*[T](self:CSet[T],x:T): CSetIter[T] {.importcpp: "#.upper_bound(#)", nodecl.}
proc begin*[T](self:CSet[T]):CSetIter[T]{.importcpp: "#.begin()", nodecl.}
proc `end`*[T](self:CSet[T]):CSetIter[T]{.importcpp: "#.end()", nodecl.}
proc `*`*[T](self:CSetIter[T]):T{.importcpp: "*#", nodecl.}
proc `++`*[T](self:CSetIter[T]){.importcpp: "++#", nodecl.}
proc `--`*[T](self:CSetIter[T]){.importcpp: "--#", nodecl.}
proc `==`*[T](x,y:CSetIter[T]):bool{.importcpp: "(#==#)", nodecl.}
proc insert*[T](self:CSet[T],x:T) {.importcpp: "#.insert(@)", nodecl.}
proc empty*[T](self:CSet[T]):bool {.importcpp: "#.empty()", nodecl.}
proc size*[T](self:CSet[T]):int {.importcpp: "#.size()", nodecl.}
proc clear*[T](self:CSet[T]) {.importcpp: "#.clear()", nodecl.}
proc erase*[T](self:CSet[T],x:T) {.importcpp: "#.erase(@)", nodecl.}
proc `==`*[T](x,y:CSet[T]):bool{.importcpp: "(#==#)", nodecl.}
# alias (var を付けないとコピーが走り危険なのでつけること)
proc add*[T](self:var CSet[T],x:T) = self.insert(x)
proc len*[T](self:var CSet[T]):int = self.size()
proc min*[T](self:var CSet[T]):T = *self.begin()
proc max*[T](self:var CSet[T]):T = (var e = self.`end`();--e; *e)
proc contains*[T](self:var CSet[T],x:T): bool{.inline.} = not (self.find(x) == self.`end`())
iterator items*[T](self:var CSet[T]) : T =
  var (a,b) = (self.begin(),self.`end`())
  while a != b : yield *a; ++a
iterator `>`*[T](self:var CSet[T],x:T) : T =
  var (a,b) = (self.upper_bound(x),self.`end`())
  while a != b : yield *a; ++a
iterator `>=`*[T](self:var CSet[T],x:T) : T =
  var (a,b) = (self.lower_bound(x),self.`end`())
  while a != b : yield *a; ++a
iterator `<=`*[T](self:var CSet[T],x:T) : T =
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
iterator `<`*[T](self:var CSet[T],x:T) : T =
  var (a,b) = (self.lower_bound(x),self.`begin`())
  if a != self.`end`():
    if *a < x : yield *a
    if a != b : # 0番だった
      --a
      while a != b :
        yield *a
        --a
      if *a < x : yield *a
iterator at*[T](self:var CSet[T],slice:Slice[T]) : T =
  var (a,b) = (self.lower_bound(slice.a),self.`end`())
  while a != b:
    if *a > slice.b : break
    yield *a; ++a
proc toSet*[T](arr:seq[T]): CSet[T] = (result = initStdSet[T]();for a in arr: result.add(a))
proc fromSet*[T](self:var CSet[T]):seq[T] = toSeq(self.items)
proc `$`*[T](self:var CSet[T]): string = $self.mapIt(it)

{.checks:off.}
when isMainModule:
  import unittest,sequtils,times
  template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
  import "../../mathlib/random"
  if false: # ベンチ
    proc checkNotExists[T](self:var CSet[T],x:T,i:int = 0):bool =
      if i == 10: return not (x in self)
      return self.checkNotExists(x,i+1)
    let n = 1e6.int
    var S = initStdSet[int]()
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
    check: toSeq(s.at(2..6)) == @[2,3,4,5,6]
    s.erase(s.max())
    check: s.max() == 6
    for _ in 0..<10: s.erase(1)
    check: s.min() == 2
    check: s == s
    # string key will be fail...
    # var ss = initStdSet[cstring]()
    # ss.add "ab".cstring
    # check: "ab".cstring in ss
    # check: "aba".cstring notin ss
