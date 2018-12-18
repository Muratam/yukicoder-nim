import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
let l = get().parseInt()
let n = get().parseInt()
echo n * (1 shl (l-3))
