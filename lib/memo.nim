# いつか実装したことのある関数をメモしておく
template useEncodeInt()=
  const INF = 10000
  proc encode(x,y:int):int = x * INF + y
  proc decodeX(i:int):int = i mod INF
  proc decodeY(i:int):int = i div INF

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

proc toAlphabet(a:int) : string = # 26進数(A..Z,AA..ZZ,...)
  proc impl(a:int) : seq[char] =
    let c = a mod 26
    let s = ('A'.ord + c).chr
    if a < 26: return @[s]
    result = impl(a div 26 - 1)
    result &= s
  return cast[string](impl(a))

template mathmatics = # 一度実装したが用途がかなり限定的な数学関数
  proc rhoFactor(n:int):int = # ポラード・ロー素因数分解法,(O(n^1/4)),1~0.1%で失敗
    proc f(x:int):int = (2 + x * x) mod n
    var (x,y,d) = (2,2,1)
    while d == 1:
      x = f(x)
      y = f(f(y))
      d = (x-y).abs.gcd(n)
    if d == n : return 0
    else : return d

  # フィボナッチ数列の第n項
  proc calcFib(n:int) : tuple[x:ModInt,y:ModInt] =
    if n == 0 : return (0.toModInt(),1.toModInt())
    let (fn,fn1) = calcFib(n div 2)
    let fnx1 = fn1 - fn
    let f2n = (fn1 + fnx1) * fn
    let f2nx1 = fn * fn + fnx1 * fnx1
    let f2n1 = f2n + f2nx1
    if n mod 2 == 0 : return (f2n,f2n1)
    else: return (f2n1,f2n1 + f2n)


  template getFactorByProcess(n:int):seq[int] = # factorコマンドで素因数分解
    import osproc
    when defined(macosx):
      const factor = "gfactor "
    else :
      const factor = "factor "
    let p = execProcess(factor & $n ).strip().split()
    p[1..p.len()-1].map(parseInt)



  # 10桁精度で計算
  template useFixed() =
    proc scanFixed(): tuple[a,b:int64] =
      var minus = false
      var now = 0
      var isA = true
      var bcnt = 10_0000_00000
      while true:
        let k = getchar_unlocked()
        if k == '-' : minus = true
        elif k == '.':
          if minus : now *= -1
          result.a = now
          now = 0
          isA = false
        elif k < '0':
          if minus : now *= -1
          if isA : result.a = now
          else: result.b = now * bcnt
          return
        else:
          now = 10 * now + k.ord - '0'.ord
          if not isA: bcnt = bcnt div 10

    proc printFixed(x:tuple[a,b:int64]) =
      var a = x.a + x.b div 10_0000_00000
      var b = x.b mod 10_0000_00000
      if (a < 0) xor (b < 0) :
        var minus = a <= 0
        if minus :
          stdout.write "-"
          a *= -1
          b *= -1
        if b mod 10_0000_00000 != 0:
          a -= 1
          b += 10_0000_00000
        if ($(b.abs)).len >= 11:
          a += 1
          b -= 10_0000_00000
      let B = "0".repeat(10 - ($(b.abs)).len) & ($b.abs)
      echo a,".",B


template iteratingMemo = # 回し方のメモ
  template getNeighbor(body) =
    for d in dxdy4:
      let nx {.inject.} = x + d.x
      let ny {.inject.} = y + d.y
      if nx < 0 or ny < 0 or nx >= w or ny >= h : continue
      body

  template bitDP =
    for i in 0..<(^n):
      for j in 0..<n:
        if j and n == 0 : continue

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





template useRankingUnionFind =
  type UnionFind[T] = ref object
    parent : seq[T]
    rank : seq[int16]
  proc root[T](self:var UnionFind[T],x:T): T =
    if self.parent[x] == x: return x
    self.parent[x] = self.root(self.parent[x])
    return self.parent[x]
  proc initUnionFind[T](size:int) : UnionFind[T] =
    new(result)
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

# マス目版のダイクストラ
proc dijkestra(E:seq[seq[int]], sx,sy:int) :seq[seq[int]] =
  type Field = tuple[x,y,v:int]
  let (W,H) = (E.len,E[0].len)
  const INF = int.high div 4
  const dxdy :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0)]
  var cost = newSeqWith(W,newSeqWith(H,INF))
  var opens = newBinaryHeap[Field](proc(a,b:Field): int = a.v - b.v)
  opens.push((sx,sy,0))
  while opens.size() > 0:
    let (x,y,v) = opens.pop()
    if cost[x][y] != INF : continue
    cost[x][y] = v
    for d in dxdy:
      let (nx,ny) = (d.x + x,d.y + y)
      if nx < 0 or ny < 0 or nx >= W or ny >= H : continue
      var n_v = v + E[nx][ny]
      if cost[nx][ny] == INF :
        opens.push((nx,ny,n_v))
  return cost


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
