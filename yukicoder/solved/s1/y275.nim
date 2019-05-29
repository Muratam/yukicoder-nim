import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
let n = get().parseInt()
let A = get().split().map(parseInt).sorted(cmp)
if n mod 2 == 1:
  echo A[n div 2]
else:
  echo((A[n div 2] + A[n div 2 - 1])/2)