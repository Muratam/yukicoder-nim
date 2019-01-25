import sequtils,algorithm,math,tables
import sets,intsets,queues,heapqueue,bitops,strutils
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc combinationWithMod(n,k:int):int = # nCk を剰余ありで
  const MOD = 1000000009
  result = 1
  let x = k.max(n - k)
  let y = k.min(n - k)
  var req = 1
  for i in 1..y: req *= i
  for i in 1..y:
    var m = n+1-i
    let g = m.gcd(req)
    m = m div g
    req = req div g
    result = (result * m) mod MOD


proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let m = scan()
let left = (n - n div (1000 * m) * 1000 * m) div 1000 # 余った1000円札の枚数
echo m.combinationWithMod(left.min(m))