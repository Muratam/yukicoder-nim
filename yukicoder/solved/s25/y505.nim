import sequtils
template times*(n:int,body) = (for _ in 0..<n: body)
proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)


proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  var minus = false
  block:
    let k = getchar_unlocked()
    if k == '-' : minus = true
    else: result = 10 * result + k.ord - '0'.ord
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': break
    result = 10 * result + k.ord - '0'.ord
  if minus: result *= -1

let n = scan()
var ansMin = scan()
var ansMax = ansMin
(n-1).times:
  let x = scan()
  let xabs = x.abs()
  var plus = ansMax + xabs
  var nextMin = plus
  var nextMax = plus
  template check(i:int) =
    nextMin .min= i
    nextMax .max= i
  check ansMin - xabs
  check ansMax * x
  check ansMin * x
  if x > 1:
    check ansMax div x
    check ansMin div x
  ansMin = nextMin
  ansMax = nextMax
printf("%ld\n",ansMax)