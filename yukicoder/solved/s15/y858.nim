proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord
# 小数点以下p桁で a / b
proc arbitraryPrecisionDiv(a,b,p:int):string =
  result = $(a div b) & "."
  var a = a
  for _ in 0..<p:
    a = a mod b
    a *= 10
    result .add $(a div b)
let a = scan()
let b = scan()
echo arbitraryPrecisionDiv(a,b,50)
