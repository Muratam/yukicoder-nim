import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
let n = get().parseInt()
let C = get().split().map(parseInt)
let s = C.sum() div 10
echo C.mapIt(if it <= s: 30 else: 0).sum()