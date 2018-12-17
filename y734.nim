import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

var (a,b,c) = get().split().map(parseInt).unpack(3)
a *= 60
c *= 3600
# n * a == c + n * b なる n
# n * (a - b) == c
if a - b <= 0: quit("-1",0)
let n = c div (a-b)
if n < 0: quit("-1",0)
if (n + 1) * a >= (n + 1) * b + c and n * a < n * b + c : echo n + 1
else: echo n