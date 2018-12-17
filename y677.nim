import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

let n = get().parseInt()
var res = newSeq[int]()
var i2 = 1
for _ in 0..n:
  var i5 = 1
  for _ in 0..n:
    res &= i2 * i5
    i5 *= 5
  i2 *= 2
echo res.sorted(cmp).mapIt($it).join("\n")