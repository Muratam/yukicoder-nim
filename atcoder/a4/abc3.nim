import sequtils,strutils,algorithm,math,future,macros,sets,tables,intsets,queues
template get*():string = stdin.readLine().strip()
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let n = get().parseInt() # 1e5
let A = get().split().map(parseInt) # 1e9
let B = get().split().map(parseInt)
# C すべて 0より大きくなるように
proc getD():seq[int]=
  result = @[]
  for i in 0..<n:
    result.add A[i] - B[i]
  return result.sorted(cmp)
let D = getD()
# B[i] ≦ A[i], sum(A) == sum(C) ,B[i] ≦ C[i]
# 総和を変えずに分配 かつ B を超えるように かつ AとCはなるべくおなじ
# Cの大きいものから順に小さいものに割当
if D.sum() < 0:
  echo -1
  quit(0)
var C = D
var res = 0
var r = n-1
var l = 0
while C[r] > 0 and C[l] < 0:
  if C[l].abs < C[r]:
    C[r] -= C[l].abs
    C[l] = 0
    l += 1
    res += 1
  elif C[l].abs > C[r]:
    C[l] += C[r].abs
    C[r] = 0
    r -= 1
    res += 1
  else:
    C[l] = 0
    C[r] = 0
    l += 1
    r += 1
    res += 2
if res > 0:
  res += 1
echo res