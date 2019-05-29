import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (n,m) = get().split().map(parseInt).unpack(2)
let L = newSeqWith(m,get())
var me = 0
var isUp = true
var draw = 0
var preDraw = 0
var C = newSeq[int](n)
proc nextTurn() =
  if isUp: me = (me + 1) mod n
  else: me = (me - 1 + n) mod n

for i,l in L:
  # echo me + 1," ",l
  if draw > 0 and not (l == "drawtwo" and preDraw == 2) and not (l == "drawfour" and preDraw == 4):
    C[me] += draw
    draw = 0
    nextTurn()
  C[me] -= 1
  case l
  of "drawtwo":
    draw += 2
    preDraw = 2
  of "drawfour":
    draw += 4
    preDraw = 4
  of "reverse": isUp = not isUp
  of "skip": nextTurn()
  else: discard
  if i == L.len() - 1:
    echo me + 1," ",-C[me]
    quit(0)
  nextTurn()
