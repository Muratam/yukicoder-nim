# https://github.com/nim-lang/Nim/issues/12184
type CSet* {.importcpp: "std::set", header: "<set>".} [T] = object
type CSetIter* {.importcpp: "std::set<'0>::iterator", header: "<set>".} [T] = object
proc cInitSet(T: typedesc): CSet[T] {.importcpp: "std::set<'*1>()", nodecl.}
proc erase*[T](self: var CSet[T],x:CSetIter[T]) {.importcpp: "#.erase(@)", nodecl.}
proc find*[T](self: CSet[T],x:T): CSetIter[T] {.importcpp: "#.find(#)", nodecl.}
proc lower_bound*[T](self: CSet[T],x:T): CSetIter[T] {.importcpp: "#.lower_bound(#)", nodecl.}
proc upper_bound*[T](self: CSet[T],x:T): CSetIter[T] {.importcpp: "#.upper_bound(#)", nodecl.}
proc begin*[T](self:CSet[T]):CSetIter[T]{.importcpp: "#.begin()", nodecl.}
proc `end`*[T](self:CSet[T]):CSetIter[T]{.importcpp: "#.end()", nodecl.}
proc `*`*[T](self: CSetIter[T]):T{.importcpp: "*#", nodecl.}
proc `++`*[T](self:var CSetIter[T]){.importcpp: "++#", nodecl.}
proc `--`*[T](self:var CSetIter[T]){.importcpp: "--#", nodecl.}
proc `==`*[T](x,y:CSetIter[T]):bool{.importcpp: "(#==#)", nodecl.}
proc initSet*[T](): CSet[T] = cInitSet(T)
proc insert*[T](self: var CSet[T],x:T) {.importcpp: "#.insert(@)", nodecl.}
proc empty*[T](self: CSet[T]):bool {.importcpp: "#.empty()", nodecl.}
proc size*[T](self: CSet[T]):int {.importcpp: "#.size()", nodecl.}
proc clear*[T](self:var CSet[T]) {.importcpp: "#.clear()", nodecl.}
proc erase*[T](self: var CSet[T],x:T) {.importcpp: "#.erase(@)", nodecl.}
proc `==`*[T](x,y:CSet[T]):bool{.importcpp: "(#==#)", nodecl.}
import sequtils # nim alias
proc add*[T](self:var CSet[T],x:T) = self.insert(x)
proc len*[T](self:CSet[T]):int = self.size()
proc min*[T](self:CSet[T]):T = *self.begin()
proc max*[T](self:CSet[T]):T = (var e = self.`end`();--e; *e)
proc contains*[T](self:CSet[T],x:T):bool = self.find(x) != self.`end`()
iterator items*[T](self:CSet[T]) : T =
  var (a,b) = (self.begin(),self.`end`())
  while a != b : yield *a; ++a
iterator `>`*[T](self:CSet[T],x:T) : T =
  var (a,b) = (self.upper_bound(x),self.`end`())
  while a != b : yield *a; ++a
iterator `>=`*[T](self:CSet[T],x:T) : T =
  var (a,b) = (self.lower_bound(x),self.`end`())
  while a != b : yield *a; ++a
iterator `<=`*[T](self:CSet[T],x:T) : T =
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
iterator `<`*[T](self:CSet[T],x:T) : T =
  var (a,b) = (self.lower_bound(x),self.`begin`())
  if a != self.`end`():
    if *a < x : yield *a
    if a != b : # 0番だった
      --a
      while a != b :
        yield *a
        --a
      if *a < x : yield *a
iterator getRange*[T](self:CSet[T],slice:Slice[T]) : T =
  for x in self >= slice.a:
    if x > slice.b : break
    yield x
proc toSet*[T](arr:seq[T]): CSet[T] = (result = initSet[T]();for a in arr: result.add(a))
proc fromSet*[T](self:CSet[T]):seq[T] = self.mapIt(it)
proc `$`*[T](self:CSet[T]): string = $self.mapIt(it)

when isMainModule:
  import unittest,sequtils
  test "C++ set":
    var s = @[3,1,4,1,5,9,2,6,5,3,5].toSet()
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
  import times,sets,intsets,algorithm,tables,hashes
  template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
  if false: # ベンチ. int->int のNim標準Table との比較
    var xorShiftVar = 88172645463325252.uint64
    xorShiftVar = cast[uint64](cpuTime()) # 初期値を固定しない場合
    proc xorShift() : uint64 =
      xorShiftVar = xorShiftVar xor (xorShiftVar shl 13)
      xorShiftVar = xorShiftVar xor (xorShiftVar shr 7)
      xorShiftVar = xorShiftVar xor (xorShiftVar shl 17)
      return xorShiftVar
    proc random(maxIndex: int): int =
      cast[int](xorShift() mod maxIndex.uint64)
    proc randomBit(maxBit:int):int = # mod が遅い場合
      cast[int](xorShift() and cast[uint64]((1 shl maxBit) - 1))
    proc shuffle[T](x: var openArray[T]) =
      for i in countdown(x.high, 1):
        swap(x[i], x[random(i)])
    let N = 1e7.int
    # O(logN)の壁は 約10倍コスト.
    # 最小値系が欲しくなったら, 数倍コストで std::set
    # データ数 1e6,ランダムケース に対して
    #    2ms: データを舐める
    #    6ms: seq[int](一括)
    #   20ms: seq[int](add)
    #  200ms: HashSet[int]() / Table[int,int]()
    #  300ms: seq[int](add).sorted(cmp)
    #  600ms: intSet
    # 1000ms: std::set[int]()

    block:
      stopwatch: # 3ms / 3ms , 爆速だね
        var S = 0
        for _ in 0..N: S += _
        echo "only sum",S mod 2
    block:
      stopwatch: # 3ms / 3ms , 爆速だね
        var S = 0
        for _ in 0..N: S += randomBit(32)
        echo "only sum rand",S mod 2
    block:
      echo "seq direct"
      stopwatch: # 7ms / 7ms , 爆速だね
        var S = newSeq[int](N+1)
        for _ in 0..N: S[_] = randomBit(32)
    block:
      echo "seq"
      stopwatch: # 20ms / 20ms , はやいね
        var S = newSeq[int]()
        for _ in 0..N: S.add randomBit(32)
    block:
      echo "seq + sort "
      stopwatch: # 40ms / 300ms , はやいね
        var S = newSeq[int]()
        for _ in 0..N: S.add randomBit(32)
        S.sort(cmp)
    block:
      echo "Hashset"
      stopwatch: # 60ms / 200ms , つよ
        var S = initHashSet[int]()
        for _ in 0..N: S.incl randomBit(32)
    block:
      echo "table"
      stopwatch: # 60ms / 200ms , つよ
        var S = initTable[int,int]()
        for _ in 0..N: S[randomBit(32)] = _
    block:
      echo "std::set"
      stopwatch: # 200ms / 1000ms , そんなもんか
        var S = initSet[int]()
        for _ in 0..N: S.add randomBit(32)
    block:
      echo "fucking intset"
      stopwatch: # 45ms / 600ms , えぇ...
        var S = initIntSet()
        for _ in 0..N: S.incl randomBit(32)
