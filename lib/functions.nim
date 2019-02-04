import sequtils,strutils,algorithm,math,sugar,macros
# import sets,tables,intsets,queues,heapqueue,bitops
# import rationals,critbits,ropes,nre,pegs,complex,stats
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
template stopwatch(body) = (let t1 = cpuTime();body;echo "TIME:",(cpuTime() - t1) * 1000,"ms")
template `^`(n:int) : int = (1 shl n)

#
template useUnsafeInput() =
  proc gets(str: untyped){.header: "<stdio.h>", varargs.}
  proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
  proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
  proc scan(): int =
    while true:
      var k = getchar_unlocked()
      if k < '0' or k > '9': break
      result = 10 * result + k.ord - '0'.ord
  proc scan(): int =
    var minus = false
    block:
      let k = getchar_unlocked()
      if k == '-' : minus = true
      else: result = 10 * result + k.ord - '0'.ord
    while true:
      let k = getchar_unlocked()
      if k < '0' or k > '9': break
      result = 10 * result + k.ord - '0'.ord
    if minus: result *= -1

#
template useUnsafeOutput() =
  proc puts(str: untyped){.header: "<stdio.h>", varargs.}
  proc puts(str: cstring){.header: "<stdio.h>", varargs.}
  proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
  proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
  proc printInt(a0:int32) =
    # if a0 < 0 : putchar_unlocked('-') # マイナスにも対応したければこれで可能
    # var a0 = a0.abs
    template div10(a:int32) : int32 = cast[int32]((0x1999999A * cast[int64](a)) shr 32)
    template put(n:int32) = putchar_unlocked("0123456789"[n])
    proc getPrintIntNimCode(n,maxA:static[int32]):string =
      result = "if a0 < " & $maxA & ":\n"
      for i in 1..n: result &= "  let a" & $i & " = a" & $(i-1) & ".div10\n"
      result &= "  put(a" & $n & ")\n"
      for i in n.countdown(1): result &= "  put(a" & $(i-1) & "-a" & $i & "*10)\n"
      result &= "  return"
    macro eval(s:static[string]): auto = parseStmt(s)
    eval(getPrintIntNimCode(0,10))
    eval(getPrintIntNimCode(1,100))
    eval(getPrintIntNimCode(2,1000))
    eval(getPrintIntNimCode(3,10000))
    eval(getPrintIntNimCode(4,100000))
    eval(getPrintIntNimCode(5,1000000))
    eval(getPrintIntNimCode(6,10000000))
    eval(getPrintIntNimCode(7,100000000))
    eval(getPrintIntNimCode(8,1000000000))
  template printInt(n:int,c:char) =
    printInt(n.int32)
    putchar_unlocked(c)

  proc printInt(a0:int) =
    # if a0 < 0 : putchar_unlocked('-') # マイナスにも対応したければこれで可能
    # var a0 = a0.abs
    template put(n:int) = putchar_unlocked("0123456789"[n])
    proc getPrintIntNimCode(n,maxA:static[int64]):string =
      result = "if a0 < " & $maxA & ":\n"
      for i in 1..n: result &= "  let a" & $i & " = a" & $(i-1) & " div 10\n"
      result &= "  put(a" & $n & ")\n"
      for i in n.countdown(1): result &= "  put(a" & $(i-1) & "-a" & $i & "*10)\n"
      result &= "  return"
    macro eval(s:static[string]): auto = parseStmt(s)
    eval(getPrintIntNimCode(0,10))
    eval(getPrintIntNimCode(1,100))
    eval(getPrintIntNimCode(2,1000))
    eval(getPrintIntNimCode(3,10000))
    eval(getPrintIntNimCode(4,100000))
    eval(getPrintIntNimCode(5,1000000))
    eval(getPrintIntNimCode(6,10000000))
    eval(getPrintIntNimCode(7,100000000))
    eval(getPrintIntNimCode(8,1000000000))
    eval(getPrintIntNimCode(9,10000000000))
    eval(getPrintIntNimCode(10,100000000000))
    eval(getPrintIntNimCode(11,1000000000000))
    eval(getPrintIntNimCode(12,10000000000000))
    eval(getPrintIntNimCode(13,100000000000000))
    eval(getPrintIntNimCode(14,1000000000000000))
    eval(getPrintIntNimCode(15,10000000000000000))
    eval(getPrintIntNimCode(16,100000000000000000))
    eval(getPrintIntNimCode(17,1000000000000000000))


# 整数位置管理用
template usePosition() =
  const dxdy4 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0)]
  const dxdy8 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0),(1,1),(1,-1),(-1,-1),(-1,1)]
  type Pos = tuple[x,y:int]
  proc `+`(p,v:Pos):Pos = (p.x+v.x,p.y+v.y)
  proc `-`(p,v:Pos):Pos = (p.x-v.x,p.y-v.y)
  proc `==`(p,v:Pos):bool = p.x == v.x and p.y == v.y
  proc `*`(p,v:Pos):Pos = (p.x*v.x,p.y*v.y)
  proc dot(p,v:Pos):int = p.x * v.x + p.y * v.y


# 10進数
template useDecimal() =
  proc toSeq(str:string):seq[char] = result = @[];(for s in str: result &= s)
  proc splitAsDecimal(n:int):auto = ($n).toSeq().mapIt(it.ord- '0'.ord)
  proc joinAsDecimal(n:seq[int]):int = n.mapIt($it).join("").parseInt()
  proc enumerate[T](arr:seq[T]): seq[tuple[i:int,val:T]] =
    result = @[]; for i,a in arr: result &= (i,a)
  # proc `*`(str:string,t:int):string = str.repeat(t)
# 二進表現
template useBitOperators() =
  # @math :: nextPowerOfTwo,isPowerOfTwo
  # @bitops
  #   popcount :: 100101010 -> 4 (1 is 4)
  #   parityBits :: 1001010 -> 1 (1 is odd)
  #   fastlog2 :: int -> int
  #   countLeadingZeroBits :: <0000>10 -> 4
  #   countTrailingZeroBits :: 01<0000> -> 4 (if 0 then 140734606624512)
  #   firstSetBit :: countTrailingZeroBits + 1 (if 0 then 0)
  #   when unsigned :: rotateLeftBits rotateRightBits
  proc factorOf2(n:int):int = n and -n # 80:0101<0000> => 16:2^4
  proc binaryToIntSeq(n:int):seq[int] =
    result = @[]
    for i in 0..64:
      if (n and ^i) > 0: result &= i + 1
      if n < ^(i+1) : return
  proc binary(x:int,reverse:bool=false):string = # 二進表示
    if x == 0 : return "0"
    result = ""
    var x = x
    while x > 0:
      result &= ('0'.ord + x mod 2).chr
      x = x div 2
    if reverse : return
    for i in 0..<result.len div 2: swap(result[i],result[result.len-1-i])

