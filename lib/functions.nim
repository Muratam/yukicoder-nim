import sequtils
# import algorithm,math,times,bitops
# import tables,intsets,sets,queues
# import macros,strutils,sugar,heapqueue
# import rationals,critbits,ropes,nre,pegs,complex,stats
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

# 実行時間/メモリ使用量解析
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
proc printMemories*() =
  proc printMem(mem: int, spec: string) =
    echo spec, " MEM:", mem div 1024 div 1024, "MB"
  getTotalMem().printMem("TOTAL")
  getOccupiedMem().printMem("OCCUP")
  getFreeMem().printMem("FREE ")

# Pos
const dxdy4 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0)]
const dxdy8 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0),(1,1),(1,-1),(-1,-1),(-1,1)]
type Pos = tuple[x,y:int]
proc `+`(p,v:Pos):Pos = (p.x+v.x,p.y+v.y)
proc dot(p,v:Pos):int = p.x * v.x + p.y * v.y

# Input
template useUnsafeInput() =
  setStdIoUnbuffered()
  proc gets(str: untyped){.header: "<stdio.h>", varargs.}
  proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
  proc scan(): int = scanf("%lld\n",addr result)
  proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>",discardable .}
  proc scan(): int =
    while true:
      var k = getchar_unlocked()
      if k < '0' or k > '9': break
      result = 10 * result + k.ord - '0'.ord
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
