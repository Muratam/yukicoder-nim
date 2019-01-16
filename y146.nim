const MOD = 1_0000_0000_7
const HIGH = int32.high
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  result = 0
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord

let n = scan()
var res = 0
for _ in 0..<n:
  var c = scan()
  var d = scan()
  c = (c+1) shr 1
  if c > HIGH : c = c mod MOD
  if d > HIGH : d = d mod MOD
  res += c * d
  if res > HIGH: res = res mod MOD
echo res