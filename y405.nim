import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

const R = ["I","II","III","IIII","V","VI","VII","VIII","IX","X","XI","XII"]
let (S,T) = get().split().unpack(2)
let t = T.parseInt()
for i,r in R:
  if S != r: continue
  let s = i
  echo R[(((s + t) mod 12) + 12 ) mod 12]
  break
