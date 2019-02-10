import sequtils,strutils
# import algorithm,math,tables
# import times,macros,queues,bitops,strutils,intsets,sets
# import rationals,critbits,ropes,nre,pegs,complex,stats,heapqueue,sugar
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc binary(x:int,fill:int=0):string = # 二進表示
  if x == 0 : return "0".repeat(fill)
  result = ""
  var x = x
  while x > 0:
    result &= ('0'.ord + x mod 2).chr
    x = x div 2
  for i in 0..<result.len div 2: swap(result[i],result[result.len-1-i])
  return "0".repeat(0.max(fill - result.len)) & result


# template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
# proc `^`(n:int) : int{.inline.} = (1 shl n)
setStdIoUnbuffered()
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

# 00000 ~ 11111 でなにがでるか確認
proc getMayRule110():seq[seq[int]] =
  result = newSeqWith(8,newSeq[int]())
  for i in 0..<32:
    let a = (i shr 2) mod 8
    let b = (i shl 1) mod 8
    let c = i mod 8
    proc rule110(b:int):int = (if b in [0,4,7] : 0 else: 1)
    result[a.rule110*4+b.rule110*2+c.rule110] &= i
const rule110 = getMayRule110()
echo rule110.mapIt(it.mapIt(it.binary(5)))
let n = scan()
let E = newSeqWith(n,scan())
var may0 = newSeqWith(n,true)
var may1 = newSeqWith(n,true)
# for b in 0..<n:
#   let a = if b == 0 : n - 1 else: b + 1
#   let c = if b == n - 1 : 0 else: b - 1
#   case E[a]*4 + E[b]*2 + E[c]:
#   of 0b000: # 00000 10000 11100
#   of 0b001: # 10010 11110 00010
#   of 0b010:
#   of 0b011:
#   of 0b100:
#   of 0b101:
#   of 0b110:
#   of 0b111:
#   else: discard