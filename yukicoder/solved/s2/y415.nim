import sequtils,strutils,algorithm,math

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
let n = scan()
let d = scan()
# 1 .. n
# 1 -> 1 + d -> ... -> (1 + d * _) mod n (足場N=足場0)
let g = n.gcd(d)
if g == 1: # 無限
  quit $(n-1), 0
if g == n: #
  quit $(0), 0
echo(n div n.gcd(d) - 1)
