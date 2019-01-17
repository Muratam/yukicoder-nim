import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

let n1 = get().parseInt()
let A = get().split().map(parseInt)
let n2 = get().parseInt()
let B = get().split().map(parseInt)
proc normalize(x,y:var int) =
  let g = x.gcd(y)
  x = x div g
  y = y div g

var x = A[0]
var y = A[1..^1].foldl(a*b,1)
for i,b in B:
  if i mod 2 == 0 : y *= b
  else: x *= b
  if x <= int32.high shl 4 and y <= int32.high shl 4: continue
if y < 0 :
  x *= -1
  y *= -1
normalize(x,y)
echo x," ",y
