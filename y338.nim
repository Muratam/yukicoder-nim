import sequtils,strutils,algorithm,math,sugar,macros,strformat
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

proc roundedDiv(a,b:int) : int =
  let c = (a * 10) div b
  if c mod 10 >= 5: return 1 + c div 10
  return c div 10

const AB = (proc():seq[seq[int]] =
  const INF = 1e4.int
  var AB = newSeqWith(101,newSeqWith(101,INF))
  for a in 0..<300:
    for b in 0..<300:
      if a == b and b == 0 : continue
      let c = (100 * a).roundedDiv(a + b)
      let d = (100 * b).roundedDiv(a + b)
      AB[c][d] .min= a + b
  return AB
)()
let a = scan()
let b = scan()
echo AB[a][b]