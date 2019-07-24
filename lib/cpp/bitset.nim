const BitSetSize = 64
type CBitSet {.importcpp: "std::bitset<"&($BitSetSize)&">", header: "<bitset>".} = object
proc initBitSet(n:uint): CBitSet {.importcpp: "std::bitset<"&($BitSetSize)&">(#)", nodecl.}
# proc resize*(self:var CVector,n:int) {.importcpp: "#.resize(#)", nodecl.}
# proc initVector*(size:int = 0): CVector = ( result = cInitVector(T); result.resize(size))
# proc size*(self: CVector):int {.importcpp: "#.size()", nodecl.}
# proc empty*(self: CVector):bool {.importcpp: "#.empty()", nodecl.}
# proc push_back*(self:var CVector,x:T) {.importcpp: "#.push_back(@)", nodecl.}
# proc `[]`*(self: CVector,key:int): T {.importcpp: "#[#]", nodecl.}
# proc `[]=`*(self:var CVector,key:int,val:T) {.importcpp: "#[#] = #", nodecl.}
# proc clear*(self:var CVector) {.importcpp: "#.clear()", nodecl.}
# proc pop_back*(self:var CVector) {.importcpp: "#.pop_back()", nodecl.}
# import sequtils # nim alias
# proc add*(self:var CVector,x:T) = self.push_back(x)
# proc len*(self:CVector):int = self.size()
# iterator items(self:CVector): T = (for i in 0..<self.len: yield self[i])
# proc toVector*(arr:seq): CVector = (result = initVector(arr.len);for i,a in arr: result[i] = a)
# proc toSeq*(self:CVector):seq = self.mapIt(it)
type StdString {.importcpp: "std::string", header: "<string>".} = object
proc c_str(a: StdString): cstring {.importcpp: "(char *)(#.c_str())".}
proc to_string(self:CBitSet):StdString{.importcpp:"#.to_string()".}
proc `$`*(self:CBitSet): cstring = self.to_string().c_str()


when isMainModule:
  import unittest
  test "C++ bitset":
    var b = initBitSet(64)
    echo b
