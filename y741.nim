import math
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

const INF = 1_0000_00007
proc combination(n,k:int):int = # nCk をすばやく誤差なく計算
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
    result = (result * m) mod INF

let n = scan()
echo (n+9).combination(9)