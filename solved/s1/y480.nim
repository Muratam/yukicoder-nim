import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
let n = get().parseInt()
echo n * (n+1) div 2
