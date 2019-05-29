import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

let n = get().parseInt()
let A = get().split().map(parseInt)
let v = get().parseInt()
echo A.sum() - v