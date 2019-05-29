import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

let n = get().parseInt()
let S = get()
let T = get()
var res = 0
for i in 0..<n:
  if S[i] != T[i] : res += 1
echo res