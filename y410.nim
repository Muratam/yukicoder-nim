import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (px,py) = get().split().map(parseInt).unpack(2)
let (qx,qy) = get().split().map(parseInt).unpack(2)
let x = abs(px-qx)
let y = abs(py-qy)
let res = x div 2 + y div 2
if x mod 2 == 1 :
  if y mod 2 == 1 :
    echo res + 1
  else:
    echo res,".5"
elif y mod 2 == 1 :
  echo res,".5"
else:
  echo res