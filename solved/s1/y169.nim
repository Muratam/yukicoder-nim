import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

let k = get().parseInt()
let s = get().parseInt()
echo s * 100 div (100-k)