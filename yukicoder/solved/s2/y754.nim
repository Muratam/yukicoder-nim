import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord

const INF = 10_0000_0007
proc MOD(x:int) :int =
  if x > INF : x mod INF
  else: x

let n = scan()
let A = newSeqWith(n+1,scan())
let B = newSeqWith(n+1,scan())
var ans = 0
var bSum = B[0]
for i in n.countdown(0):
  ans = MOD(ans + A[i] * bSum)
  bSum = MOD(bSum + B[n-i+1])
echo ans