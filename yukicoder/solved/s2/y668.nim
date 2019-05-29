proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
# 3つとる
let a = getchar_unlocked().ord - '0'.ord
let b = getchar_unlocked().ord - '0'.ord
let c = getchar_unlocked().ord - '0'.ord
var n = 10 * a + b + (if c >= 5: 1 else: 0)
var e = 2
if n > 99:
  e = 3
  n = n div 10
stdout.write n div 10
stdout.write "."
stdout.write n mod 10
stdout.write "*10^"
while getchar_unlocked() >= '0': e += 1
echo e
