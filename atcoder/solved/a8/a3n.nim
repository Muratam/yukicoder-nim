import sequtils,strutils,algorithm,math,macros,future
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  result = 0
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord
let n = scan()
let q = scan()
let S = stdin.readLine()
var T = newSeqWith(q,'A')
var isR = newSeqWith(q,false)
for i in 0..<q:
  T[i] = getchar_unlocked()
  discard getchar_unlocked()
  isR[i] = getchar_unlocked() == 'R'
  discard getchar_unlocked()
# 左端
var L = -1
var R = n
var rt = -1
var lt = -1
for i in (q-1).countdown(0):
  #echo((L:L,R:R,isR:isR[i],T:T[i]))
  # 左端が一つ増えた
  if isR[i]:
    #if L - 1 >= 0 and T[i] == S[L-1]:
    #  L -= 1
    if R - 1 >= 0 and T[i] == S[R-1]:
      R -= 1
      rt = i
  else:
    if L + 1 < n and T[i] == S[L+1]:
      L += 1
      lt = i
    #if R + 1 < n and T[i] == S[R+1]:
    #  R += 1
for i in (q-1).countdown(0):
  if isR[i]:
    if L >= 0 and T[i] == S[L] and i < lt:
      L -= 1
  else:
    if R < n and T[i] == S[R] and i < rt:
      R += 1
#echo((L:L,R:R))
#echo((lm:lm,rm:rm))
echo( n - 0.max(L+1) - 0.max(n-R))
