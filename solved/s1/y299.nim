import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
let n = get().parseInt()
echo 316 + 52 * (n - 1)