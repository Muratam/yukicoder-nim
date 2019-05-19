import sequtils
template times*(n:int,body) = (for _ in 0..<n: body)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
# 木やんけ
# ∑3回以上登場しているもの-2
var E = newSeq[int](n+1)
(2*n-2).times: E[scan()] += 1
var ans = 0
for e in E: ans += 0.max(e-2)
echo ans
