# import sequtils,strutils,algorithm,math,macros
# import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
# template times*(n:int,body) = (for _ in 0..<n: body)
# template `max=`*(x,y) = x = max(x,y)
# template `min=`*(x,y) = x = min(x,y)
# proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
# proc scan(): int =
#   while true:
#     let k = getchar_unlocked()
#     if k < '0' or k > '9': return
#     result = 10 * result + k.ord - '0'.ord

let an = scan()
let bn = scan()
let A = newSeqWith(an,scan())
let B = newSeqWith(bn,scan())
var dp = newSeqWith(an+1,newSeqWith(bn+1,0))
# for
# 若い順にとれる
# start player の最大値
# {a0} | max{a0,b0} |
