import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
let n = get().parseInt()
let A = newSeqWith(n,get().parseInt())
var cnt = 1
var me = A[0]
echo 1
for a in A[1..^1]:
  if a > me: cnt += 1
  echo cnt