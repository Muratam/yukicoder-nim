# だめなやつだけど爆速
proc gets(str: cstring){.header: "<stdio.h>", varargs.}
# 負の要素がある場合のscan
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>",discardable .}
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

# Output
template useUnsafeOutput() =
  setStdIoUnbuffered()
  proc puts(str: untyped){.header: "<stdio.h>", varargs.}
  proc puts(str: cstring){.header: "<stdio.h>", varargs.}
  proc fputs(c: cstring, f: File) {.importc: "fputs", header: "<stdio.h>",tags: [WriteIOEffect].}
  template put(c:untyped) = fputs(cstring(c),stdout)
  proc funlockfile(f:File) {.importc: "funlockfile", header:"<stdio.h>" .}
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
