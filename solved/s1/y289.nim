import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

let S = get()
var res = 0
for s in S:
  if s.ord >= '0'.ord and s.ord <= '9'.ord: res += s.ord - '0'.ord
echo res