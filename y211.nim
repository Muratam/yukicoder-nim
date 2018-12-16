import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

let n = get().parseInt()
let A = [2,3,5,7,11,13]
let B = [4,6,8,9,10,12]
var res = 0
for a in A:
  for b in B:
    if a * b == n : res += 1
echo res / 36