import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
let n = get().parseInt
let S = newSeqWith(n,get())
for s in S:
  var si = s.mapIt(it.ord - '0'.ord)
  while si.len != 1:
    var nexts = newSeq[int]()
    for i in 0..<si.len-1:
      let si2 = si[i] + si[i+1]
      if si2 < 10 : nexts &= si2
      else: nexts &= 1 + si2 mod 10
    si = nexts
  echo si[0]