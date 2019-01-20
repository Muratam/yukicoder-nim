import sequtils,strutils,algorithm,math

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
let n = scan()
let A = newSeqWith(n,scan()).sorted(cmp)
let B = newSeqWith(n,scan()).sorted(cmp)
var AX = A
var cnt = 0
var win = 0
while true:
  var BX = B
  while true:
    cnt += 1
    var aWin = 0
    var bWin = 0
    for i in 0..<n:
      if AX[i] > BX[i] : aWin += 1
      if AX[i] < BX[i] : bWin += 1
    if aWin > bWin : win += 1
    if not nextPermutation(BX) : break
  if not nextPermutation(AX): break
echo win / cnt
