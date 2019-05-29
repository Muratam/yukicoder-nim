import strutils,bitops
var n = stdin.readLine().parseInt()
var ans = 0
while n > 1:
  if n mod 2 == 0:
    let z = n.countTrailingZeroBits()
    ans += z
    n = n shr z
  else:
    ans += 1
    n += 1
echo ans
# 1 から始めて x2 or -1
# 10010011_1_00 -> 10010_0111 -> 10010_1000 -> 100101 ...