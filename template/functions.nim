const INF = int.high div 4
const dxdy4 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0)]
const dxdy8 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0),(1,1),(1,-1),(-1,-1),(-1,1)]

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

# prime factor power parseDecimal
template mathUtils():untyped =
  proc getIsPrimes(n:int) :seq[bool] = # [0...n]
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

  proc power(x,n:int,modulo:int = 0): int =
    #繰り返し二乗法での x ** n
    if n == 0: return 1
    if n == 1: return x
    let
      pow_2 = power(x,n div 2,modulo)
    result = pow_2 * pow_2 * (if n mod 2 == 1: x else: 1)
    if modulo > 0: result = result mod modulo

  proc parseDecimal(n:int) : seq[int] =
    result = @[]; for it in $n: result &= it.ord - '0'.ord

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
  proc coundDuplicate[T](arr:seq[T]): auto =
    arr.sorted(cmp[T]).foldl(
      if a[^1].key == b:
        a[0..<a.len-1] & (b, a[^1].val+1)
      else:
        a & (b, 1),
      @[ (key:arr[0],val:1) ])
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
