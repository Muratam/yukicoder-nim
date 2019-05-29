template times*(n:int,body) = (for _ in 0..<n: body)
proc power(x,n:int): int =
  if n <= 1: return if n == 1: x else: 1
  let pow_2 = power(x,n div 2)
  return pow_2 * pow_2 * (if n mod 2 == 1: x else: 1)
setStdIoUnbuffered()
var ans = 1
3.times:
  let S = stdin.readLine()
  if S == "NONE" : ans *= 1 shl 8
  else:
    let n = 16 - (S.len + 1) div 2
    ans *= power(n,2)
echo ans