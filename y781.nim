import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template `max=`*(x,y) = x = max(x,y)
proc sqrt(x:int):int = x.float.sqrt.int

var results : array[1000_0010,int16]
const INF = 1000_0000
const SQRTINF = INF.sqrt
for a in 0..SQRTINF: results[a * a] += 1
for a in 0..SQRTINF div 2: results[2 * a * a] += 1
for a in 1..SQRTINF:
  for b in (a+1)..sqrt(INF - a * a):
    var c = a * a + b * b
    results[c] += 2

let (x,y) = get().split().map(parseInt).unpack(2)
var ans = 0
for r in x..y: ans .max= results[r]
echo ans * 4
