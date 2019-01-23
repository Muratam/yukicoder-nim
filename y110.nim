import sequtils
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
let nw = scan()
let W = newSeqWith(nw,scan())
let nb = scan()
let B = newSeqWith(nb,scan())
# W が下
proc check(isB:bool) : int =
  var size = if isB: B.max() else: W.max()
  var isB = not isB
  result = 1
  while true:
    let C = if isB : B else: W
    let cf =  C.filterIt(it < size)
    if cf.len == 0 : return
    size = cf.max()
    isB = not isB
    result += 1
echo check(true).max(check(false))