import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (a,b,c) = get().split().map(parseInt).unpack(3)
proc f(x:int) : int =
  const tooBig = (4e18.int).fastLog2()
  let s =  a+b-1
  let t = x div a
  if t > 1 and fastLog2(s) + fastLog2(t) > tooBig : return 4e18.int
  return x mod a + s * t
var x = 1
var y = 1e18.int + 10
while true:
  if c <= f(y) and f(y-1) < c: quit $y,0
  let m = (x+y) div 2
  if f(m) < c : x = m
  else : y = m
# 1 2 3 4  a     a+1   ... 2a
# 1 2 3 4 [4+b]  []+1  ... 2[]
# f(n) = (n%a) + [b+(a-1)] * ((n-1)/a)
#      = n%a + (a+b-1)*((n-1)/a) > c