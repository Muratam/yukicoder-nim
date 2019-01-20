import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (a,b,c) = get().split().map(parseInt).unpack(3)
if a == c or a == b or b == c : quit("0",0)
if a < b and b > c or a > b and b < c : quit("INF",0)
var res = 0
for i in 1..max([a,b,c]):
  let (d,e,f) = (a mod i,b mod i,c mod i)
  if (d < e and e > f or d > e and e < f) and (d != e and e != f and d != f):
    res += 1
echo res