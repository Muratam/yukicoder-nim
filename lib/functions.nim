import sequtils,strutils,algorithm,math,sugar,macros
# import sets,tables,intsets,queues,heapqueue,bitops
# import rationals,critbits,ropes,nre,pegs,complex,stats
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc toCountSeq[T](x:seq[T]) : seq[tuple[k:T,v:int]] = toSeq(x.toCountTable().pairs)


#
template useUnsafeInput() =
  proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
  proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
  proc scan(): int =
    while true:
      var k = getchar_unlocked()
      if k < '0' or k > '9': break
      result = 10 * result + k.ord - '0'.ord
  proc scan(): int =
    var minus = false
    while true:
      var k = getchar_unlocked()
      if k == '-' : minus = true
      elif k < '0' or k > '9': break
      else: result = 10 * result + k.ord - '0'.ord
    if minus: result *= -1
#
template useUnsafeOutput() =
  proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
  proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
  proc printInt(a:int32) =
    if a == 0:
      putchar_unlocked('0')
      return
    template div10(a:int32) : int32 = cast[int32]((0x1999999A * cast[int64](a)) shr 32)
    template mod10(a:int32) : int32 = a - (a.div10 * 10)
    var n = a
    var rev = a
    var cnt = 0
    while rev.mod10 == 0:
      cnt += 1
      rev = rev.div10
    rev = 0
    while n != 0:
      rev = rev * 10 + n.mod10
      n = n.div10
    while rev != 0:
      putchar_unlocked((rev.mod10 + '0'.ord).chr)
      rev = rev.div10
    while cnt != 0:
      putchar_unlocked('0')
      cnt -= 1
  proc printInt(a:int,last:char) =
    a.int32.printInt()
    putchar_unlocked(last)

  proc printInt(a:int32) =
    template div10(a:int32) : int32 = cast[int32]((0x1999999A * cast[int64](a)) shr 32)
    template put(n:int32) = putchar_unlocked("0123456789"[n])
    if a < 10:
      put(a)
      return
    if a < 100:
      let a1 = a.div10
      (put(a1);put(a-a1*10))
      return
    if a < 1000:
      let a1 = a.div10
      let a2 = a1.div10
      put(a2)
      put(a1-a2*10)
      put(a-a1*10)
      return
    if a < 10000:
      let a1 = a.div10
      let a2 = a1.div10
      let a3 = a2.div10
      put(a3)
      put(a2-a3*10)
      put(a1-a2*10)
      put(a-a1*10)
      return

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
  #   firstlog2 :: int -> int
  #   countLeadingZeroBits :: <0000>10 -> 4
  #   countTrailingZeroBits :: 01<0000> -> 4 (if 0 then 140734606624512)
  #   firstSetBit :: countTrailingZeroBits + 1 (if 0 then 0)
  #   when unsigned :: rotateLeftBits rotateRightBits
  proc factorOf2(n:int):int = n and -n # 80:0101<0000> => 16:2^4
  template optPow{`^`(2,n)}(n:int) : int = 1 shl n
  proc binary(x:int,reverse:bool=false):string = # 二進表示
    if x == 0 : return "0"
    result = ""
    var x = x
    while x > 0:
      result &= ('0'.ord + x mod 2).chr
      x = x div 2
    if reverse : return
    for i in 0..<result.len div 2: swap(result[i],result[result.len-1-i])


