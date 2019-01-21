import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
let S = stdin.readLine()
var ans = 1
for k in 3.countup(S.len(),2):
  if (proc () : bool =
    for i in 0..<S.len():
      for j in 0..<k:
        if S[i+j] != S[i+k-1-j] : return false
    return true
  )() : ans = k
echo ans