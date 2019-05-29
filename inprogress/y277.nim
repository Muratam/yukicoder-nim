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

let n = scan()
var E = newSeqWith(n,newSeq[int]())
(n-1).times:
  let src = scan() - 1
  let dst = scan() - 1
  E[src] &= dst
var answers = newSeq[int](n)
proc solve(i,rank:int):int =
  if E[i].len == 0:
    answers[i] = 0
    return 0
  result = rank
  for dst in E[i]:
    result .min= solve(dst,rank+1) + 1
  answers[i] = result

discard solve(0,0)
for i in 0..<n:
  answers[i].int32.printInt()
  putchar_unlocked('\n')