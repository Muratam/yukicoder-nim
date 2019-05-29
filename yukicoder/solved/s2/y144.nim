import sequtils,strutils
let S = stdin.readLine().split()
let n = S[0].parseInt()
let p = S[1].parseFloat()
# 候補:[2,3,4,5,6,7,8,9,10]
# 素数:[]
# [3,4,5,6,7,8,9,10] ->
var A = newSeqWith(n+1,1.0)
var c = 0.0
for i in 2..n:
  # echo i,":",A
  c += A[i]
  for j in 2..n:
    let b = i * j
    if b > n: break
    A[b] *= 1.0 - p
echo c