# 二軍 small template
template optPow{`^`(2,n)}(n:int) : int = 1 shl n
template If*(ex:untyped):untyped = (if not(ex) : continue)
const INF = int.high div 4
const dxdy4 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0)]
const dxdy8 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0),(1,1),(1,-1),(-1,-1),(-1,1)]

template io():untyped =
  # when loooong readline()
  template fgets(f:File,buf:untyped,size:int):void =
    proc c_fgets(c: cstring, n: int, file: File): void {.importc: "fgets", header: "<stdio.h>", tags: [ReadIOEffect].}
    var buf: array[size, char]
    c_fgets(buf,sizeof((buf)),f)

# bitset
template bitsetOperators():untyped =
  proc `+=`[T](x:var set[T],y:T):void = x.incl(y)
  proc `-=`[T](x:var set[T],y:T):void = x.excl(y)
  proc `+=`[T](x:var set[T],y:set[T]):void = x = x.union(y)
  proc `*=`[T](x:var set[T],y:set[T]):void = x = x.intersection(y)
  proc `-=`[T](x:var set[T],y:set[T]):void = x = x.difference(y)
  converter toInt8(x:int) : int8 = x.toU8()

# %=  //=  gcd= lcm=
template assignOperators():untyped =
  template `%=`*(x,y:typed):void = x = x mod y
  template `//=`*(x,y:typed):void = x = x div y
  template `gcd=`*(x,y:typed):void = x = gcd(x,y)
  template `lcm=`*(x,y:typed):void = x = lcm(x,y)

# prime factor power parseDecimal,probAdd
template mathUtils():untyped =

  proc millerRabinIsPrime(n:int):bool = # O(log n)
    proc ctz(n:int):cint{.importC: "__builtin_ctz", noDecl .} # 01<0000> -> 4
    proc power(x,n:int,modulo:int = 0): int =
      if n == 0: return 1
      if n == 1: return x
      let pow_2 = power(x,n div 2,modulo)
      result = pow_2 * pow_2 * (if n mod 2 == 1: x else: 1)
      if modulo > 0: result = result mod modulo
    if n <= 1 : return false
    if n div 2 == 0: return false
    if n == 2 or n == 3 or n == 5: return true
    let
      s = ctz(n - 1)
      d = (n - 1) div (1 shl s)
    var a_list = @[2, 7, 61]
    if n >= 4_759_123_141 and n < 341_550_071_728_321:
      a_list = @[2, 3, 5, 7, 11, 13, 17]
    if n in a_list : return true
    for a in a_list:
      if power(a,d,n) == 1 : continue
      let notPrime = toSeq(0..<s).allIt(power(a,d*(1 shl it),n) != n-1)
      if notPrime : return false
    return true
  proc squareFormFactor(n:int):int =
    #if millerRabinIsPrime(n) : return n
    proc check(k:int):int =
      proc √(x:int):int = x.float.sqrt.int
      if n <= 1 : return n
      if n mod 2 == 0 : return 2
      if √(n) * √(n) == n : return √(n)
      var P,Q = newSeq[int]()
      block:
        P &= √(k * n)
        Q &= 1
        Q &= k * n - P[0]*P[0]
      while √(Q[^1]) * √(Q[^1]) != Q[^1]:
        let b = (√(k * n) + P[^1] ) div Q[^1]
        P &= b * Q[^1] - P[^1]
        Q &= Q[^2] + b * (P[^2] - P[^1])
      block:
        if Q[^1] == 0 : return check(k + 1)
        let
          b = (√(k * n) - P[^1] ) div Q[^1]
          P0 = b * √(Q[^1]) + P[^1]
          Q0 = √(Q[^1])
          Q1 = (k*n - P0*P0) div Q0
        (P,Q) = (@[P0], @[ Q0, Q1 ])
      while true:
        let b = (√(k * n) + P[^1] ) div Q[^1]
        P &= b * Q[^1] - P[^1]
        Q &= Q[^2] + b * (P[^2] - P[^1])
        if P[^1] == P[^2] or Q[^1] == Q[^2]: break
      let f = gcd(n,P[^1])
      if f != 1 and f != n : return f
      else: return check(k+1)
    return check(1)

  proc rhoFactor(n:int):int = # (O(n/4)),1~0.1%で失敗
    proc f(x:int):int = (2 + x * x) mod n
    var (x,y,d) = (2,2,1)
    while d == 1:
      x = f(x)
      y = f(f(y))
      d = gcd(abs(x-y),n)
    if d == n : return 0
    else : return d

  proc getIsPrimes(n:int) :seq[bool] = # [0...n] O(n loglog n)
    result = newSeqWith(n+1,true)
    result[0] = false
    result[1] = false
    for i in 2..n.float.sqrt.int :
      if not result[i]: continue
      for j in countup(i*2,n,i):
        result[j] = false

  proc getPrimes(n:int):seq[int] = # [2,3,5,...n]
    let isPrimes = getIsPrimes(n)
    result = @[]
    for i,p in isPrimes:
      if p : result &= i

  proc getFactors(N:int):seq[int] =
    let primes = getPrimes(N.float.sqrt.int + 1)
    var n = N
    result = @[]
    for p in primes:
      if p >= n : break
      while n mod p == 0:
        result &= p
        n = n div p
    if n != 1:
      result &= n
  template getFactorByProcess(n:int):seq[int] =
    import osproc
    when defined(macosx):
      const factor = "gfactor "
    else :
      const factor = "factor "
    let p = execProcess(factor & $N ).strip().split()
    p[1..p.len()-1].map(parseInt)



  proc power(x,n:int,modulo:int = 0): int =
    if n == 0: return 1
    if n == 1: return x
    let
      pow_2 = power(x,n div 2,modulo)
      odd = if n mod 2 == 1: x else: 1
    if modulo > 0:
      result = (pow_2 * odd) mod modulo
      result = (result * pow_2) mod modulo
    else :
      result = pow_2 * pow_2 * odd

  proc powerBig(x,n:int,modulo:int = 0): int =
    proc mul(x,n,modulo:int):int =
      if n == 0: return 0
      if n == 1: return x
      result = mul(x,n div 2,modulo) mod modulo
      result = (result * 2) mod modulo
      result = (result + x * (n mod 2 == 1).int) mod modulo
      if n == 0: return 1
    if n == 1: return x
    let
      pow_2 = powerBig(x,n div 2,modulo)
      odd = if n mod 2 == 1: x else: 1
    if modulo > 0:
      const maybig = int.high.float.sqrt.int div 2
      if pow_2 > maybig or odd > maybig:
        result = mul(pow_2,pow_2,modulo)
        result = mul(result,odd,modulo)
      else:
        result = (pow_2 * pow_2) mod modulo
        result = (result * odd) mod modulo
    else:
      return pow_2 * pow_2 * odd


  proc parseDecimal(n:int) : seq[int] =
    result = @[]; for it in $n: result &= it.ord - '0'.ord
  proc probAdd(ps,qs:seq[float]):seq[float] =
    result = newSeqWith(ps.len + qs.len - 1,0.0)
    for i,p in ps:
      for j,q in qs:
        result[i + j] += p * q


# transpose matIt ...
template matrixUtils():untyped =
  proc transpose*[T](mat:seq[seq[T]]):seq[seq[T]] =
    result = newSeqWith(mat[0].len,newSeq[T](mat.len))
    for x,xs in mat: (for y,ys in xs:result[y][x] = mat[x][y])
  proc `+`[T](mat1,mat2:seq[seq[T]]):seq[seq[T]] = #matIt(mat1,mat2, a + b)
    result = mat1; for x,xs in mat2: (for y,ys in xs:result[x][y] += mat2[x][y])
  proc `-`[T](mat1,mat2:seq[seq[T]]):seq[seq[T]] =
    result = mat1; for x,xs in mat2: (for y,ys in xs:result[x][y] -= mat2[x][y])
  template matIt*[T](matA,matB:seq[seq[T]],op:untyped):seq[seq[T]] =
    var result = matA
    for x {.inject.},xs in mat:
      for y{.inject.},ys in xs:
        let a {.inject.} = matA[x][y]
        let b {.inject.} = matB[x][y]
        result[x][y] = op
    result
# clz ctz ...
template bitOperators():untyped =
  # (countBits32 isPowerOfTwo nextPowerOfTwo)
  proc clz(n:int):cint{.importC: "__builtin_clz", noDecl .} # <0000>10 -> 4
  proc ctz(n:int):cint{.importC: "__builtin_ctz", noDecl .} # 01<0000> -> 4
# toSeq int{split,join} countDuplicate enumerate ...
template seqUtils():untyped =
  proc toSeq(str:string):seq[char] = result = @[];(for s in str: result &= s)
  proc split(n:int):auto = ($n).toSeq().mapIt(it.ord- '0'.ord)
  proc join(n:seq[int]):int = n.mapIt($it).join("").parseInt()

  proc toCountedTable*[A](keys: openArray[A]): CountTable[A] =
    result = initCountTable[A](nextPowerOfTwo(keys.len * 3 div 2 + 4))
    for key in items(keys): result[key] = 1 + (if key in result : result[key] else: 0)

  proc coundDuplicate[T](keys:openArray[T]): seq[tuple[key:T,val:int]] =
    var ct = initCountTable[T](nextPowerOfTwo(keys.len * 3 div 2 + 4))
    for k in items(keys): ct[k] = 1 + (if k in ct : ct[k] else: 0)
    return toSeq(ct.pairs)

  proc enumerate[T](arr:seq[T]): seq[tuple[i:int,val:T]] =
    result = @[]; for i,a in arr: result &= (i,a)

# rep each eachit ...
template iterations():untyped =
  template each*[T](arr:var seq[T],i,a,body:untyped):untyped =
    for i in 0..<arr.len:(var a{.inject.}=arr[i]; body; defer:arr[i]=a)
  template eachIt*[T](arr:var seq[T],i,body:untyped):untyped =
    for i in 0..<arr.len:(var it{.inject.}=arr[i]; body; defer:arr[i]=it)
  template rep*(i:untyped,n:int,body:untyped):untyped =
    block:(var i = 0; while i < n:( body; i += 1))
  template each*[T](arr:var seq[T],a,body:untyped):untyped =
    for i in 0..<arr.len:(var a{.inject.}=arr[i]; body; defer:arr[i]=a)
  template eachIt*[T](arr:var seq[T],body:untyped):untyped =
    for i in 0..<arr.len:(var it{.inject.}=arr[i]; body; defer:arr[i]=it)
# dijekstra ...
template searching():untyped =
  proc dijkestra(L:seq[seq[int]], startX,startY:int,
                 diffSeq:seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0)]) :auto =
    type field = tuple[x,y,v:int]
    let (W,H) = (L.len,L[0].len)
    const INF = int.high div 4
    var cost = newSeqWith(W,newSeqWith(H,INF))
    var opens = newBinaryHeap[field](proc(a,b:field): int = a.v - b.v)
    opens.push((startX,startY,0))
    while opens.size() > 0:
      let (x,y,v) = opens.pop()
      if cost[x][y] != INF : continue
      cost[x][y] = v
      for d in diffSeq:
        let (nx,ny) = (d.x + x,d.y + y)
        if nx < 0 or ny < 0 or nx >= W or ny >= H : continue
        var n_v = v + L[nx][ny]
        if cost[nx][ny] == INF :
          opens.push((nx,ny,n_v))
    return cost
# Vec2(int) + - * len
template geometory():untyped =
  type Vec2 = object
  x,y: int
  proc `+`(p,v:Vec2):Vec2 = result.x = p.x+v.x; result.y = p.y+v.y
  proc `-`(p,v:Vec2):Vec2 = result.x = p.x-v.x; result.y = p.y-v.y
  proc `*`(p,v:Vec2):int = p.x * v.x + p.y * v.y
  proc sqlen(p:Vec2):int = p * p

template deprecated():untyped =
  # proc coundDuplicate[T](arr:openArray[T]): seq[tuple[key:T,val:int]] =
  #   # 種類が多い時にはこっちの方が速いかも ?
  #   var arr2 = arr.sorted(cmp[T])
  #   result = @[(arr2[0],1)]
  #   for a in arr2[1..arr2.len()-1]:
  #     if result[^1].key == a:
  #       result[^1].val += 1
  #     else:
  #       result &= (a,1)
