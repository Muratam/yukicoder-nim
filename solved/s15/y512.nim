import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (x,y) = get().split().map(parseInt).unpack(2)
let n = get().parseInt()
let A = get().split().map(parseInt).mapIt(it)
for i in 1..<A.len():
  if A[i] * x < A[i-1] * y : quit("NO",0)
echo "YES"