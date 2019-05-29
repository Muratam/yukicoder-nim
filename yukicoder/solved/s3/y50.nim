import sequtils,macros,algorithm,intsets
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
template `^`(n:int) : int = (1 shl n)
proc `in`(a,b:int) : bool {.inline.}= (((1 shl a) and (1 shl b)) == (1 shl a))
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

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
let A = newSeqWith(n,scan())
var state = newSeq[int](^n)
for ni in 0..<(^n):
  for ia in 0..<n:
    if (ni and ^ia) != ^ia : continue
    state[ni] += A[ia] # 各状態の体積の和

proc getOKState(b:int): seq[bool] =
  result = newSeq[bool](^n)
  for i,s in state:
    if b - s >= 0 : result[i] = true

let m = scan()
let B = newSeqWith(m,scan()).sorted(cmp,Descending)
var ans = B[0].getOKState()
if ans[^n - 1]: quit("1",0)
for i,b in B[1..^1]:
  var pre = ans
  var bAns = b.getOKState()
  for x in 0..<(^n):
    if not bAns[x] : continue
    for y in 0..<(^n):
      if not pre[y] : continue
      if (x and y) != 0 : continue
      ans[x xor y] = true
  if ans[^n - 1]:
    printInt(i + 2,'\n')
    quit 0
putchar_unlocked('-')
putchar_unlocked('1')
putchar_unlocked('\n')
