import sequtils,math,tables
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc puts(str: cstring){.header: "<stdio.h>", varargs.}

proc getFactorNumsAllRange(n:int):seq[seq[int]] =
  # 1 ~ n まで全ての素因数を列挙
  result = newSeqWith(n+1,newSeq[int]())
  for i in 2..n.float.sqrt.int :
    if result[i].len != 0: continue
    result[i] &= 1
    for j in countup(i*2,n,i):
      var t = 0
      var x = j
      while x mod i == 0:
        t += 1
        x = x div i
      result[j] &= t #mod 3
  for i in n.float.sqrt.int..n:
    if result[i].len == 0 : result[i] = @[1]
const factors = getFactorNumsAllRange(10010)#.mapIt(it.foldl(a xor b,0))
echo factors
# proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
# proc scan(): int =
#   while true:
#     let k = getchar_unlocked()
#     if k < '0': return
#     result = 10 * result + k.ord - '0'.ord

# let n = scan()
# var ans = 0
# n.times: ans = ans xor factors[scan()]
# if ans != 0 : puts "Alice"
# else: puts "Bob"