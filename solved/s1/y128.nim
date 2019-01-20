import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

let n = get().parseInt()
let m = get().parseInt()
echo( (n div (1000 * m)) * 1000)
