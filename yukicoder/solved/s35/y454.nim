import sequtils,strutils,math
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let x = stdin.readLine().parseFloat()
var ans = 0.0
for i in 1000000.countdown(1):
  let n = i.float
  ans += x * (x + 2.0 * n) / (n * n * (x + n) * (x + n))
echo PI * PI / 6 - ans