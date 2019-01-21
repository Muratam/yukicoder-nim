template times*(n:int,body) = (for _ in 0..<n: body)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
let n = scan()
let d = scan()
var preT = 0
var preK = - 1e10.int
n.times:
  let t = scan()
  let k = scan()
  (preT,preK) = (max(preT , preK - d) + t,max(preT - d , preK) + k)
echo preT.max(preK)