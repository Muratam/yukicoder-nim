import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (a,b) = newSeqWith(2,get().split(".").map(parseInt)).unpack(2)
proc isOld():bool =
  for i in 0..<3:
    if a[i] > b[i] : return true
    if a[i] < b[i] : return false
  return true
if isOld(): echo "YES"
else: echo "NO"