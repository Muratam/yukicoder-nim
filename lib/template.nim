import sequtils,algorithm,math,tables,sets,strutils,times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
template time*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

# Input
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>",discardable .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    result = 10 * result + k.ord - '0'.ord
proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc scan(): int = scanf("%lld\n",addr result)

# Output
proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
proc puts(str: cstring){.header: "<stdio.h>", varargs.}

# 実行時間 / メモリ使用量
import times
template timeUpSearch*(milliSec:int,body) =
  let startTime = cpuTime() # 時間計測行為は1000倍遅く.1e5 回で100ms.
  while (cpuTime() - startTime) * 1000 < milliSec:
    for i in 0..<100: body
proc printMemories*() =
  proc printMem(mem: int, spec: string) =
    echo spec, " MEM:", mem div 1024 div 1024, "MB"
  getTotalMem().printMem("TOTAL")
  getOccupiedMem().printMem("OCCUP")
  getFreeMem().printMem("FREE ")
# 呪文
setStdIoUnbuffered()
# Pos
const dxdy4 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0)]
const dxdy8 :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0),(1,1),(1,-1),(-1,-1),(-1,1)]
type Pos = tuple[x,y:int]
proc `+`(p,v:Pos):Pos = (p.x+v.x,p.y+v.y)
proc `-`(p,v:Pos):Pos = (p.x-v.x,p.y-v.y)

# # queues は <= 0.18 , heapqueue は => 0.18 ,intsets はHashSet[int]の完全下位互換
# import queues,heapqueue,critbits,ropes,nre,pegs
# import bitops,stats,rationals,complex,intsets,,macros,sugar,future
