import sequtils,strutils,strscans,algorithm,math,future,macros,rationals
template get*():string = stdin.readLine()
proc toSeq(str:string):seq[char] = result = @[];(for s in str: result &= s)
proc split(n:int):auto = ($n).toSeq().mapIt(it.ord- '0'.ord)

proc factorize(base:var int, n:int):int =
  result = 0
  while base mod n == 0:
    result += 1
    base = base div n

let
  N = get().parseInt()
  M = get().parseInt()
var
  r = (N // M) * (1//1)
  (n,m) = (r.num,r.den)
  m2 = m.factorize(2)
  m5 = m.factorize(5)
if m != 1 : echo -1 # 2,5以外があるとダメ
elif m2 > m5 : echo 5
elif m2 == m5 : echo n.split().filterIt(it != 0)[^1] # / 1000
elif m2 < m5 : echo n.split()[^1].`*`(1 shl (m5 - m2)).split()[^1] # /1000に