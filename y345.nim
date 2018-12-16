import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()

let S = get()
var res = newSeq[int]()
proc find(start:int) =
  var is1st = true
  for i in start..<S.len():
    let s = S[i]
    if s != 'w': continue
    if is1st: is1st = false
    else:
      res &= i - start + 1
      return

for i,s in S:
  if s == 'c': find(i + 1)
if res.len > 0 : echo res.sorted(cmp)[0] + 1
else :echo -1