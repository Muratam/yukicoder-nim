import sequtils,math,strutils

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord


proc scanFixed(): tuple[a,b:int64] = # 10桁精度
  var minus = false
  var now = 0
  var isA = true
  var bcnt = 10_0000_00000
  while true:
    let k = getchar_unlocked()
    if k == '-' : minus = true
    elif k == '.':
      if minus : now *= -1
      result.a = now
      now = 0
      isA = false
    elif k < '0':
      if minus : now *= -1
      if isA : result.a = now
      else: result.b = now * bcnt
      return
    else:
      now = 10 * now + k.ord - '0'.ord
      if not isA: bcnt = bcnt div 10

proc printFixed(x:tuple[a,b:int64]) =
  var a = x.a + x.b div 10_0000_00000
  var b = x.b mod 10_0000_00000
  if (a < 0) xor (b < 0) :
    var minus = a <= 0
    if minus :
      stdout.write "-"
      a *= -1
      b *= -1
    if b mod 10_0000_00000 != 0:
      a -= 1
      b += 10_0000_00000
    if ($(b.abs)).len >= 11:
      a += 1
      b -= 10_0000_00000
  let B = "0".repeat(10 - ($(b.abs)).len) & ($b.abs)
  echo a,".",B


let n = scan()
let F = newSeqWith(n,scanFixed())
let aSum = F.mapIt(it.a).sum()
let bSum = F.mapIt(it.b).sum()
printFixed((aSum,bSum))