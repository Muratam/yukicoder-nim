import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables
template get():string = stdin.readLine()
template times(n:int,body:untyped): untyped = (for _ in 0..<n: body)

proc power(x,n:int,modulo:int = 0): int =
  if n == 0: return 1
  if n == 1: return x
  let
    pow_2 = power(x,n div 2,modulo)
  result = pow_2 * pow_2 * (if n mod 2 == 1: x else: 1)
  if modulo > 0: result = result mod modulo

var x,N = 0
(x,N) = get().split().map(parseInt)
let a_seq = get().split().map(parseInt)
const modulo = 1_000_003
var res = 0
for a in a_seq:
  res += power(x,a,modulo)
  res = res mod modulo
echo res