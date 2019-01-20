import sequtils
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord

let n = scan()
let m = scan()
let A = newSeqWith(n,scan())
let UV = newSeqWith(m,(scan()-1,scan()-1))
var E = newSeqWith(n,newSeq[int]())
for uv in UV:
  E[uv[0]] &= uv[1]
  E[uv[1]] &= uv[0]

for i,dsts in E:
  let y = A[i]
  for j in 0..<dsts.len():
    let x = A[dsts[j]]
    for k in (j+1)..<dsts.len():
      let z = A[dsts[k]]
      if x == z : continue
      if (x < y and y > z) or (x > y and y < z) :
        quit "YES", 0
echo "NO"