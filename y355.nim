import sequtils,algorithm,math,tables
import sets,intsets,queues,heapqueue,bitops,strutils
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

proc findAll(A:seq[int]) =
  # 4(最大24回)
  var A = A.sorted(cmp)
  while true:
    echo A.mapIt($it).join(" ")
    let n = scan()
    let m = scan()
    if n == 4: break
    if not A.nextPermutation(): break

proc findNums() : seq[int] =
  proc check(A:seq[int]) : int =
    echo A.mapIt($it).join(" ")
    let n = scan()
    let m = scan()
    if n == 4:quit(0)
    return n + m
  var A = @[0,1,2,3]
  var pre = A.check()
  if pre == 4 : return A
  for b in 4..9:
    let preA = A.mapIt(it)
    var B = newSeq[int](4)
    template tryB(n) =
      A[n] = b
      B[n] = A.check()
      if B[n] == 4 : return A
      if B[n] > pre:
        A[n] = b
        pre = B[n]
        continue
      A[n] = preA[n]
    tryB(0)
    tryB(1)
    tryB(2)
    tryB(3)
findNums().findAll()