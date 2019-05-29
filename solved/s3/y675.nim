import sequtils,times,macros
proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
template stopwatch(body) = (let t1 = cpuTime();body;echo "TIME:",(cpuTime() - t1) * 1000,"ms")
template stopwatch(body) = body

# GC_disableMarkAndSweep()
proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
proc printInt(a0:int) =
  if a0 < 0 : putchar_unlocked('-') # マイナスにも対応したければこれで可能
  var a0 = a0.abs
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

stopwatch:
  let n = scan()
  let px = scan()
  let py = scan()
  var Q,V,X,Y : array[100010,int]
  for i in 0..<n:
    Q[i] = scan()
    if Q[i] == 3 : continue
    V[i] = scan()
  var M = @[@[1,0,0],@[0,1,0],@[0,0,1]]
stopwatch:
  let p = @[px,py,1]
  for i in (n-1).countdown(0):
    let q = Q[i]
    let v = V[i]
    if q == 3:
      for i in 0..<3:
        (M[0][i],M[1][i]) = (-M[1][i],M[0][i])
    elif q == 2:
      for i in 0..<3:
        M[2][i] += v * M[1][i]
    else:
      for i in 0..<3:
        M[2][i] += v * M[0][i]
    X[i] = M[0][0] * px + M[1][0] * py + M[2][0]
    Y[i] = M[0][1] * px + M[1][1] * py + M[2][1]
stopwatch:
  for i in 0..<n:
    X[i].printInt()
    putchar_unlocked(' ')
    Y[i].printInt()
    putchar_unlocked('\n')
    # printf("%d %d\n",X[i],Y[i])
