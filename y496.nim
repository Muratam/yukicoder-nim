import sequtils,macros
template times*(n:int,body) = (for _ in 0..<n: body)
template `min=`*(x,y) = x = min(x,y)

proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
proc printInt(a0:int32) =
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

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord
const INF = 1e10.int
let gx = scan()
let gy = scan()
let n = scan()
let f = scan()
var dp : array[101,array[101,int]]
for x in 0..gx:
  for y in 0..gy:
    dp[x][y] = f * (x + y)
n.times:
  let cx = scan()
  let cy = scan()
  let cost = scan()
  for x in (gx-cx).countdown(0):
    for y in (gy-cy).countdown(0):
      dp[x+cx][y+cy] .min= dp[x][y] + cost
dp[gx][gy].int32.printInt()
putchar_unlocked('\n')