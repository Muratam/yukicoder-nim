import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

let n = get().parseInt()
let XY = newSeqWith(n,get().split().map(parseInt)).mapIt(it[1] - it[0]).sorted(cmp)
if XY[0] == XY[^1] and XY[0] > 0 : echo XY[0]
else: echo -1
