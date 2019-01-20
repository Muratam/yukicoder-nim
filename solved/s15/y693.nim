import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
let n = get().parseInt()
let A = get().split().map(parseInt).sorted(cmp)
echo toSeq(1..n).mapIt(abs(it-A[it-1])).sum()