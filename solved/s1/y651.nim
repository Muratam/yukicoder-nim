import sequtils,strutils,algorithm,math,sugar,macros,strformat
import times
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let f = initTimeFormat("HH:mm")
let start = "10:00".parse(f)
let n = (get().parseInt() * 60) div 100
echo((start + n.minutes).format(f))
