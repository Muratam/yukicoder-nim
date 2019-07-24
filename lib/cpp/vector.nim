type CVector* {.importcpp: "std::vector", header: "<vector>".} [T] = object
proc cInitVector(T: typedesc): CVector[T] {.importcpp: "std::vector<'*1>()", nodecl.}
proc resize*[T](self:var CVector[T],n:int) {.importcpp: "#.resize(#)", nodecl.}
proc initVector*[T](size:int = 0): CVector[T] = ( result = cInitVector(T); result.resize(size))
proc size*[T](self: CVector[T]):int {.importcpp: "#.size()", nodecl.}
proc empty*[T](self: CVector[T]):bool {.importcpp: "#.empty()", nodecl.}
proc push_back*[T](self:var CVector[T],x:T) {.importcpp: "#.push_back(@)", nodecl.}
proc `[]`*[T](self: CVector[T],key:int): T {.importcpp: "#[#]", nodecl.}
proc `[]=`*[T](self:var CVector[T],key:int,val:T) {.importcpp: "#[#] = #", nodecl.}
proc `==`*[T](x,y:CVector[T]):bool{.importcpp: "#==#", nodecl.}
proc `<`*[T](x,y:CVector[T]):bool{.importcpp: "#<#", nodecl.}
proc clear*[T](self:var CVector[T]) {.importcpp: "#.clear()", nodecl.}
proc pop_back*[T](self:var CVector[T]) {.importcpp: "#.pop_back()", nodecl.}
import sequtils # nim alias
proc add*[T](self:var CVector[T],x:T) = self.push_back(x)
proc len*[T](self:CVector[T]):int = self.size()
iterator items*[T](self:CVector[T]): T = (for i in 0..<self.len: yield self[i])
proc toVector*[T](arr:seq[T]): CVector[T] = (result = initVector[T](arr.len);for i,a in arr: result[i] = a)
proc toSeq*[T](self:CVector[T]):seq[T] = self.mapIt(it)
proc `$`*[T](self:CVector[T]): string = $self.toSeq()

when isMainModule:
  import unittest
  test "C++ vector":
    var vec = @[11,12,13].toVector()
    var vec2 = vec
    vec .add 14
    vec2[0] = 0
    check: vec[0] == 11
    check: vec2[0] == 0
    check: vec[3] == 14
