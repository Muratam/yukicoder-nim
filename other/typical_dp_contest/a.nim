import sequtils,intsets
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord

var dp = initIntSet()
dp.incl 0
for i in 0..<scan():
  let p = scan()
  let keys = toSeq(dp.items)
  for k in keys:
    dp.incl k
    dp.incl k+p
echo toSeq(dp.items).len
