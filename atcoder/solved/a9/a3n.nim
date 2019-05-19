import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
var ans = 0
var bsa = 0
var sa = 0
var bs = 0
n.times:
  let S = stdin.readLine()
  for i in 1..<S.len:
    if S[i-1] == 'A' and S[i] == 'B' :
      ans += 1
  if S[0] == 'B' and S[^1] == 'A' : bsa += 1
  elif S[0] == 'B' : bs += 1
  elif S[^1] == 'A' : sa += 1

# echo sa
# echo bs
# echo bsa
# echo ans
if bsa >= 1:
  ans += bsa - 1
  bsa = 1
  if sa >= 1 and bs >= 1:
    ans += 2
    sa -= 1
    bs -= 1
    ans += min(sa,bs)
  elif sa >= 1 or bs >= 1 :
    ans += 1
else:
  ans += min(sa,bs)

echo ans
