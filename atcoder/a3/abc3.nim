import sequtils,strutils,algorithm,math,future,macros,sets,tables,intsets,queues
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let nmd = stdin.readline().split().map(parseInt)
let (n,m,d) = (nmd[0],nmd[1],nmd[2])
# [1..n] の ながさ m の数列の美しさの平均
# 差の絶対値がdであるものをさがす (3,2,3,10,9) :
# 1..10 の長さ 5 -> 3 3 8 8 3
let w = if d == 0: 1 else:2
echo (w * (n-d) * (m-1)).float() / (n * n).float