# いつか実装したことのある関数をメモしておく
template useEncodeInt()=
  const INF = 10000
  proc encode(x,y:int):int = x * INF + y
  proc decodeX(i:int):int = i mod INF
  proc decodeY(i:int):int = i div INF

proc toAlphabet(a:int) : string = # 26進数(A..Z,AA..ZZ,...)
  proc impl(a:int) : seq[char] =
    let c = a mod 26
    let s = ('A'.ord + c).chr
    if a < 26: return @[s]
    result = impl(a div 26 - 1)
    result &= s
  return cast[string](impl(a))


proc evalPlusMinusExpression(S:string): tuple[ok:bool,val:int] = # 012+223-123+...
  if S[0] == '+'  or S[0] == '-'  : return (false,0)
  if S[^1] == '+' or S[^1] == '-' : return (false,0)
  var minus = false
  var val = 0
  var ans = 0
  for i,s in S:
    if '0' <= s and s <= '9' :
      val = 10 * val + s.ord - '0'.ord
      if i != S.len - 1 : continue
    if minus : ans -= val
    else: ans += val
    val = 0
    minus = s == '-'
  return (true,ans)


proc printInt(a:int) =
  if a == 0:
    putchar_unlocked('0')
    return
  var n = a
  var rev = a
  var cnt = 0
  while rev mod 10 == 0:
    cnt += 1
    rev = rev div 10
  rev = 0
  while n != 0:
    rev = rev * 10 + n mod 10
    n = n div 10
  while rev != 0:
    putchar_unlocked((rev mod 10 + '0'.ord).chr)
    rev = rev div 10
  while cnt != 0:
    putchar_unlocked('0')
    cnt -= 1

proc printFloat(a,b:int) =
  if a == 0:
    putchar_unlocked('0')
  else:
    printInt(a div b)
    if a mod b != 0:
      putchar_unlocked('.')
      const leaving = 100000
      let r = (a * leaving div b) mod leaving
      var l = leaving div 10
      while l > r :
        putchar_unlocked('0')
        l = l div 10
      printInt(r,true)
  putchar_unlocked('\n')



template imos2() =
  proc imos2Reduce(field:typed) =
    for x in field.low + 1 .. field.high:
      for y in field[x].low .. field[x].high:
        field[x][y] += field[x-1][y]
    for x in field.low .. field.high:
      for y in field[x].low + 1 .. field[x].high:
        field[x][y] += field[x][y-1]
  proc imos2Regist(field:typed,x1,y1,x2,y2:int,val:typed) =
    field[x1][y1] += val
    field[x1][y2+1] -= val
    field[x2+1][y1] -= val
    field[x2+1][y2+1] += val

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

template useRankingUnionFind =
  type UnionFind[T] = object
    parent : seq[T]
    rank : seq[int16]
  proc root[T](self:var UnionFind[T],x:T): T =
    if self.parent[x] == x: return x
    self.parent[x] = self.root(self.parent[x])
    return self.parent[x]
  proc initUnionFind[T](size:int) : UnionFind[T] =
    result.parent = newSeqUninitialized[T](size)
    result.rank = newSeq[int16](size)
    for i in 0.int32..<size.int32: result.parent[i] = i
  proc same[T](self:var UnionFind[T],x,y:T) : bool = self.root(x) == self.root(y)
  proc unite[T](self:var UnionFind[T],sx,sy:T) : bool {.discardable.} =
    let rx = self.root(sx)
    let ry = self.root(sy)
    if rx == ry : return false
    self.parent[rx] = ry
    if self.rank[rx] < self.rank[ry] : self.parent[rx] = ry
    else:
      self.parent[ry] = rx
      if self.rank[rx] == self.rank[ry]: self.rank[rx] += 1
    return true



template plagmas() = discard
  #pragma GCC target ("sse4") #=>  __builtin_popcount系が 機械語 popcnt に
  #pragma GCC optimize ("fast-math") #=> 浮動小数点系の高速化(+精度の悪化)
  #{.checks: off, optimization: speed.} / {. global .}
#
template useCountTable() =
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
# 区間スケジューリング : それを選んだ時に選べなく鳴るものが最も少ないものから順に
