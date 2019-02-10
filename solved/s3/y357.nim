import sequtils
template `^`(n:int) : int = (1 shl n)
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc `in`(a,b:int) : bool {.inline.}= (((1 shl a) and (1 shl b)) == (1 shl a))

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let m = scan()
var S = newSeqWith(n,newSeq[int](n))
m.times:
  let a = scan()
  let b = scan()
  let s = scan()
  S[a][b] = s
var dp : array[^14,int]
for x in 0..<(^n):
  for i in 0..<n:
    if ^i in x : continue
    var s = 0
    for j in 0..<n:
      if ^j in x : continue
      s += S[j][i]
    dp[x or ^i] .max= dp[x] + s
echo dp[^n-1]