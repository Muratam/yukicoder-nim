import sequtils,strutils,algorithm,math,sugar,macros,strformat
template times*(n:int,body) = (for _ in 0..<n: body)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord
const P = [2,3,5,7,11,13]
const C = [4,6,8,9,10,12]
let pn = scan()
let cn = scan()
var ans = 1.0
pn.times: ans *= P.sum().float / 6.0
cn.times: ans *= C.sum().float / 6.0
echo ans