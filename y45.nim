import sequtils,strutils
let
  N = stdin.readLine()
  V = stdin.readLine().split().map(parseInt)
var ok,no = 0
for v in V: (no,ok) = (ok + v,max(ok,no))
echo max(ok,no)