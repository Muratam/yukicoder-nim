import sequtils,strutils,algorithm
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let sum = scan()
let cnt = scan()
var ans = toSeq(1..cnt)
let sumOfAns = (cnt + 1) * cnt div 2
if sumOfAns > sum : quit "-1",0
var left = sum - sumOfAns
var maxN = n
for i in (cnt-1).countdown(0):
  let diff = left.min(maxN - ans[i])
  if diff < 0 : quit "-1",0
  left -= diff
  ans[i] += diff
  maxN = min(ans[i],maxN) - 1
  if diff != 0 and i != 0 : continue
  if left == 0 : break
  quit "-1",0
echo ans.mapIt($it).join(" ")