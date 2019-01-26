import sequtils,algorithm,bitops
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord


let n = scan()
let A = newSeqWith(n,scan())
proc solve(s:int=0,now:int=0) : int =
  if s.popcount == n : return now
  for i in 0..<n:
    if ((1 shl i) and s) > 0 : continue
    for j in (i+1)..<n:
      if ((1 shl j) and s) > 0 : continue
      result .max= solve(s or (1 shl i) or (1 shl j),now xor (A[i] + A[j]))
    # 最高のペアが分かったのでbreakしてよい
    break
echo solve()