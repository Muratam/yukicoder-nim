{.checks:off.}
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
  var a = self.upper_bound(x)
  var b = self.`begin`()
  var e = self.`end`()
  echo a == e
  if a != e:
    if *a <= x : yield *a
    if a != b : # 0番だった
      --a
      while a != b :
        yield *a
        --a
      if *a <= x : yield *a
iterator `<`*[T](self:var CMultiSet[T],x:T) : T =
  var (a,b) = (self.lower_bound(x),self.`begin`())
  if a != self.`begin`():
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
proc `$`*[T](self:var CMultiSet[T]): string = $self.fromMultiSet()

import sequtils,algorithm,math,tables,sets,strutils,times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
template loop*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord


stopwatch:
  let n = scan()
  let m = 1 shl n
  var B = newSeq[int](m)
  for i in 0..<m:B[i] = scan()
  var S = initStdMultiSet[int]()
  for b in B: S.add b
  var parent = newSeq[int]()
  block:
    let last = S.max()
    parent.add last
    S.erase last
  n.loop:
    var child = newSeq[int]()
    for p in parent:
      # p未満のものを一つだけ削除する
      var ok = false
      echo toSeq(S <= 100)
      echo toSeq(S < -100)
      echo S,p
      for last in S <= p:
        ok = true
        child.add last
        S.erase last
        break
      echo ok
      if not ok:
        quit "No",0
    parent.add child
  echo "Yes"
