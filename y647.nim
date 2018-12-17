import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let n = get().parseInt
let AB = newSeqWith(n,get().split().map(parseInt).unpack(2))
# A円以内 B辛以上
let m = get().parseInt
let XY = newSeqWith(m,get().split().map(parseInt).unpack(2))
# X円 Y辛
var res = newSeq[int](m)
for i,xy in XY:
  for ab in AB:
    if ab[0] >= xy[0] and ab[1] <= xy[1] :
      res[i] += 1
let maxRes = res.max()
if maxRes == 0: quit("0",0)
for i,r in res:
  if r == maxRes: echo i + 1