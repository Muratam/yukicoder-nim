import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

let n = get().parseInt()
let A = newSeqWith(n,get().split().mapIt(it == "nyanpass"))
var res = newSeq[int]()
for i in 0..<n:
  var ok = true
  for j in 0..<n:
    if i == j : continue
    if not A[j][i]: ok = false
  if ok: res &= i

if res.len == 1: echo res[0] + 1
else: echo -1