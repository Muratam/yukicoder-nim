import sequtils,times,lists
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
template stopwatch(body) = (let t1 = cpuTime();body;echo "TIME:",(cpuTime() - t1) * 1000,"ms")
template stopwatch(body) = body
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
# 31634
let n = scan()
var E : array[100010,SinglyLinkedList[int]]
var preHasCutDP : array[100010,int]
var preHasNotCutDP : array[100010,int]
stopwatch:
  (n-1).times:
    let u = scan() - 1
    let v = scan() - 1
    E[u].prepend(v)
    E[v].prepend(u)
stopwatch:
  for i in 0..<n:
    preHasCutDP[i] = -1
    preHasNotCutDP[i] = -1
  proc solve(preHasCut:bool,x:int,preX:int):int =
    if preHasCut and preHasCutDP[x] != -1 : return preHasCutDP[x]
    if not preHasCut and preHasNotCutDP[x] != -1 : return preHasNotCutDP[x]
    var whenCut = 0
    for e in E[x]:
      if e != preX : whenCut += solve(true,e,x)
    if preHasCut:
      var whenNotCut = 1
      for e in E[x]:
        if e != preX : whenNotCut += solve(false,e,x)
      result = max(whenCut,whenNotCut)
      preHasCutDP[x] = result
      preHasNotCutDP[x] = max(whenCut,whenNotCut-1)
    else:
      result = whenCut
      preHasNotCutDP[x] = result
stopwatch: echo solve(true,0,-1)