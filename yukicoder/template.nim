import sequtils,algorithm,math,tables,sets,strutils,times
template time*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord
# proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
# proc scan(): int = scanf("%lld\n",addr result)

let n = scan()
let A = newSeqWith(n,scan())
