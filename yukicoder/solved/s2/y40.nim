import sequtils,macros
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
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
proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
proc printInt(a0:int32) =
  if a0 < 0 : putchar_unlocked('-')
  var a0 = a0.abs
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
let n = scan()
var A = newSeqWith(n+1,scan())
for i in countdown(n, 3): A[i-2] += A[i]
if n >= 2 and A[2] != 0:
  printInt(2,'\n')
  printInt(A[0],' ')
  printInt(A[1],' ')
  printInt(A[2],'\n')
elif n >= 1 and A[1] != 0:
  printInt(1,'\n')
  printInt(A[0],' ')
  printInt(A[1],' ')
else:
  printInt(0,'\n')
  printInt(A[0],' ')