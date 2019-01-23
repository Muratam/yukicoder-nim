template useEncodeInt()=
  const INF = 10000
  proc encode(x,y:int):int = x * INF + y
  proc decodeX(i:int):int = i mod INF
  proc decodeY(i:int):int = i div INF



# += -= *= | %=  //=  gcd= lcm=
template useAssignOperators() =
  proc `+=`[T](x:var set[T],y:T) = x.incl(y)
  proc `-=`[T](x:var set[T],y:T) = x.excl(y)
  proc `+=`[T](x:var set[T],y:set[T]) = x = x.union(y)
  proc `*=`[T](x:var set[T],y:set[T]) = x = x.intersection(y)
  proc `-=`[T](x:var set[T],y:set[T]) = x = x.difference(y)
  template `%=`*(x,y:typed) = x = x mod y
  template `//=`*(x,y:typed) = x = x div y
  template `gcd=`*(x,y:typed) = x = gcd(x,y)
  template `lcm=`*(x,y:typed) = x = lcm(x,y)
  converter toInt8(x:int) : int8 = x.toU8()
  # %=  //=  gcd= lcm=



template plagmas() = discard
  #pragma GCC target ("sse4") #=>  __builtin_popcount系が 機械語 popcnt に
  #pragma GCC optimize ("fast-math") #=> 浮動小数点系の高速化(+精度の悪化)
  #{.checks: off, optimization: speed.} / {. global .}
#
template useFastCountTable() =
  proc toCountedTable*[A](keys: openArray[A]): CountTable[A] =
    result = initCountTable[A](nextPowerOfTwo(keys.len * 3 div 2 + 4))
    for key in items(keys): result[key] = 1 + (if key in result : result[key] else: 0)
  proc countDuplicate[T](keys:openArray[T]): seq[tuple[key:T,val:int]] =
    var ct = initCountTable[T](nextPowerOfTwo(keys.len * 3 div 2 + 4))
    for key in items(keys): ct[key] = 1 + (if k in ct : ct[key] else: 0)
    return toSeq(ct.pairs)

proc probAdd(ps,qs:seq[float]):seq[float] =
  result = newSeqWith(ps.len + qs.len - 1,0.0)
  for i,p in ps:
    for j,q in qs:
      result[i + j] += p * q
