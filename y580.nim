import sequtils,algorithm
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': break
    result = 10 * result + k.ord - '0'.ord

proc parseLine(): tuple[x,y:int] =
  result.x = scan() * 1440 + scan() * 60 + scan()
  result.y = scan() * 1440 + scan() * 60 + scan()

proc swapSortDescending(arr:var seq[int],index:int) =
  # 10-9-6-3-7-2-1 を直す
  for i in 0..<arr.len:
    if arr[i] >= arr[index] : continue
    for j in i..<index:
      # if arr[j] == arr[index] : return
      swap(arr[j],arr[index])
    return
let n = scan()
let m = scan()
let U = newSeqWith(m,parseLine()).sortedByIt(it.y)
var preY = newSeq[int](n)
var ans = 0
for u in U:
  for i in 0..<n:
    if preY[i] >= u.x: continue
    preY[i] = u.y
    ans += 1
    preY.swapSortDescending(i)
    break
echo ans