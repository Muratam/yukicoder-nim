import sequtils,strutils,algorithm,math,sugar,macros,strformat
import times
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
let f = initTimeFormat("HH:mm")
let (n,h,m,t) = get().split().map(parseInt).unpack(4)
let start = fmt"{h:02}:{m:02}".parse(f)
let wake = start + (t * (n-1)).minutes
echo wake.hour
echo wake.minute