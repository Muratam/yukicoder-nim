import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let n = get().parseInt()
let A = get().split().map(parseInt)
var res = 0
for i in 0..<n-2:
  let (a,b,c) = A[i..i+2].unpack(3)
  if a == c : continue
  if a < b and b > c: res += 1
  if a > b and b < c: res += 1
echo res