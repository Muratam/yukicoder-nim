import sequtils
template times*(n:int,body) = (for _ in 0..<n: body)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord

type CMultiSet {.importcpp: "std::multiset", header: "<set>".} [T] = object
type CMultiSetIter {.importcpp: "std::multiset<'0>::iterator", header: "<set>".} [T] = object
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
proc `end`*[T](self:CMultiSet[T]):CMultiSetIter[T]{.importcpp: "#.end()", nodecl.} # 注: keyword end と被るので `end` として使う
proc `*`*[T](self: CMultiSetIter[T]):T{.importcpp: "*#", nodecl.}
proc `++`*[T](self:var CMultiSetIter[T]){.importcpp: "++#", nodecl.} # 注:前置のみ
proc `--`*[T](self:var CMultiSetIter[T]){.importcpp: "--#", nodecl.} # 注:前置のみ
proc eqRawImpl[T](x,y:CMultiSetIter[T]):bool{.importcpp: "#==#", nodecl.}
proc eqRawImpl[T](x,y:CMultiSet[T]):bool{.importcpp: "#==#", nodecl.}
proc `==`*[T](x,y:CMultiSetIter[T]):bool = not(not(x.eqRawImpl y)) # a != b を !a == b とNimコンパイラが変換するので、
proc `==`*[T](x,y:CMultiSet[T]):bool = not(not(x.eqRawImpl y))     # コンパイルに失敗する可能性を防ぐための処置
import sequtils # nim alias
proc add*[T](self:var CMultiSet[T],x:T) = self.insert(x)
proc len*[T](self:CMultiSet[T]):int = self.size()
proc min*[T](self:CMultiSet[T]):T = *self.begin()
proc max*[T](self:CMultiSet[T]):T = (var e = self.`end`();--e; *e)
proc contains*[T](self:CMultiSet[T],x:T):bool = self.find(x) != self.`end`()
iterator items*[T](self:CMultiSet[T]) : T =
  var (a,b) = (self.begin(),self.`end`())
  while a != b : yield *a; ++a
proc `>`*[T](self:CMultiSet[T],x:T) : seq[T] =
  var (a,b) = (self.upper_bound(x),self.`end`())
  result = @[]; while a != b :result .add *a; ++a
proc `>=`*[T](self:CMultiSet[T],x:T) : seq[T] =
  var (a,b) = (self.lower_bound(x),self.`end`())
  result = @[]; while a != b :result .add *a; ++a
proc toMultiSet*[T](arr:seq[T]): CMultiSet[T] = (result = initMultiSet[T]();for a in arr: result.add(a))
proc toSeq[T](self:CMultiSet[T]):seq[T] = self.mapIt(it)
proc `$`*[T](self:CMultiSet[T]): string = $self.mapIt(it)


let n = scan()
let m = 1 shl n
var S = initMultiSet[int]()
m.times: S.insert(scan())
var parent = newSeq[int]()
block: # last
  var it = S.`end`()
  --it
  parent.add *it
  S.erase it
n.times:
  var child = newSeq[int]()
  for p in parent:
    var it = S.lowerBound(p)
    if it == S.begin(): # は？
      quit "No",0
    --it
    child.add *it
    S.erase it
  parent.add child
echo "Yes"
