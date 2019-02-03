import sequtils

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

const fibs = (proc():seq[int] =
  result = newSeq[int](80)
  result[0] = 1
  result[1] = 1
  for i in 2..<80:
    result[i] = result[i-1] + result[i-2]
)()
let n = scan()
let m = scan()
var should = fibs[n-1]
if should == m : quit "0", 0
var ans = 0
for i in (n-3).countdown(0):
  if should - fibs[i] == 0 :
    ans += 1
    break
  if should - fibs[i] < m : continue
  should -= fibs[i]
  ans += 1
if should != m : quit "-1",0
echo ans