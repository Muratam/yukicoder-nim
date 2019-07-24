const allowMulti = false
when not allowMulti:
  type CSet {.importcpp: "std::set", header: "<set>".} [T] = object
  type CSetIter {.importcpp: "std::set<'0>::iterator", header: "<set>".} [T] = object
  proc cInitSet(T: typedesc): CSet[T] {.importcpp: "std::set<'*1>()", nodecl.}
else:
  type CSet {.importcpp: "std::multiset", header: "<set>".} [T] = object
  type CSetIter {.importcpp: "std::multiset<'0>::iterator", header: "<set>".} [T] = object
  proc cInitSet(T: typedesc): CSet[T] {.importcpp: "std::multiset<'*1>()", nodecl.}
proc initSet*[T](): CSet[T] = cInitSet(T)
proc insert*[T](self: var CSet[T],x:T) {.importcpp: "#.insert(@)", nodecl.}
proc empty*[T](self: CSet[T]):bool {.importcpp: "#.empty()", nodecl.}
proc size*[T](self: CSet[T]):int {.importcpp: "#.size()", nodecl.}
proc clear*[T](self:var CSet[T]) {.importcpp: "#.clear()", nodecl.}
proc erase*[T](self: var CSet[T],x:T) {.importcpp: "#.erase(@)", nodecl.}
proc find*[T](self: CSet[T],x:T): CSetIter[T] {.importcpp: "#.find(#)", nodecl.}
proc lower_bound*[T](self: CSet[T],x:T): CSetIter[T] {.importcpp: "#.lower_bound(#)", nodecl.}
proc upper_bound*[T](self: CSet[T],x:T): CSetIter[T] {.importcpp: "#.upper_bound(#)", nodecl.}
proc begin*[T](self:CSet[T]):CSetIter[T]{.importcpp: "#.begin()", nodecl.}
proc `end`*[T](self:CSet[T]):CSetIter[T]{.importcpp: "#.end()", nodecl.}
proc `*`*[T](self: CSetIter[T]):T{.importcpp: "*#", nodecl.}
proc `++`*[T](self:var CSetIter[T]){.importcpp: "++#", nodecl.}
proc `--`*[T](self:var CSetIter[T]){.importcpp: "--#", nodecl.}
proc `==`*[T](x,y:CSetIter[T]):bool{.importcpp: "#==#", nodecl.}
proc `==`*[T](x,y:CSet[T]):bool{.importcpp: "#==#", nodecl.}
import sequtils # nim alias
proc add*[T](self:var CSet[T],x:T) = self.insert(x)
proc len*[T](self:CSet[T]):int = self.size()
proc min*[T](self:CSet[T]):T = *self.begin()
proc max*[T](self:CSet[T]):T = (var e = self.`end`();--e; *e)
proc contains*[T](self:CSet[T],x:T):bool = self.find(x) != self.`end`()
iterator items*[T](self:CSet[T]) : T =
  var (a,b) = (self.begin(),self.`end`())
  while a != b : yield *a; ++a
proc `>`*[T](self:CSet[T],x:T) : seq[T] =
  var (a,b) = (self.upper_bound(x),self.`end`())
  result = @[]; while a != b :result .add *a; ++a
proc `>=`*[T](self:CSet[T],x:T) : seq[T] =
  var (a,b) = (self.lower_bound(x),self.`end`())
  result = @[]; while a != b :result .add *a; ++a
proc toSet*[T](arr:seq[T]): CSet[T] = (result = initSet[T]();for a in arr: result.add(a))
proc toSeq*[T](self:CSet[T]):seq[T] = self.mapIt(it)
proc `$`*[T](self:CSet[T]): string = $self.toSeq()

when not allowMulti:
  import tables
  # key:int が順序付きのMap
  # WARN: 不完全
  type Map[T] = object
    indice : CSet[int]
    table : Table[int,T]
  proc initMap*[T]() : Map[T] = Map[T](indice:initSet[int](),table:initTable[int,T]())
  proc empty*[T](self: Map[T]):bool = self.indice.empty()
  proc len*[T](self: Map[T]):int = self.indice.len()
  proc clear*[T](self:var Map[T]) = (self.indice.clear(); self.table.clear())
  proc erase*[T](self: var Map[T],x:T) = (self.indice.erase(x);self.table.del(x))
  proc `[]=`*[T](self: var Map[T],k:int,v:T) =
    self.indice.add k
    self.table[k] = v
  import sequtils # nim alias
  proc `[]`*[T](self:var Map[T],k:int): T = self.table[k]
  proc minKey*[T](self:Map[T]):T = *self.indice.begin()
  proc maxKey*[T](self:Map[T]):T = (var e = self.indice.`end`();--e; *e)
  proc contains*[T](self:Map[T],x:T):bool = self.indice.find(x) != self.indice.`end`()
  proc `>`*[T](self:Map[T],x:T) : seq[(int,T)] =
    var (a,b) = (self.indice.upper_bound(x),self.indice.`end`())
    result = @[]; while a != b :result .add((*a,self.table[*a])); ++a
  proc `>=`*[T](self:Map[T],x:T) : seq[(int,T)] =
    var (a,b) = (self.lower_bound(x),self.`end`())
    result = @[]; while a != b :result .add((*a,self.table[*a])); ++a
  proc `$`*[T](self:Map[T]): string = $self.table

when isMainModule:
  import unittest,sequtils
  test "C++ set":
    var s = @[3,1,4,1,5,9,2,6,5,3,5].toSet()
    check: 8 notin s
    check: s.min() == 1
    check: s.max() == 9
    when allowMulti:
      check: s.len == 11
      check: s > 4 == @[5, 5, 5, 6, 9]
      check: s >= 4 == @[4, 5, 5, 5, 6, 9]
    else:
      check: s.len == 7
      check: s > 4 == @[5, 6, 9]
      check: s >= 4 == @[4, 5, 6, 9]
    s.erase(s.max())
    check: s.max() == 6
    for _ in 0..<10: s.erase(1)
    check: s.min() == 2
  # test "C++ set to map":
  #   if not  allowMulti:
  #     var s = initMap[string]()
  #     for i in [3,1,4,1,5,9,2,6,5,3,5]:
  #       s[i] = $i
  #     echo s
