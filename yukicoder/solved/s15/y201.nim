import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
let (sa,pa,_) = get().split().unpack(3)
let (sb,pb,_) = get().split().unpack(3)
if pa == pb: quit "-1", 0
if pa.len > pb.len : quit sa, 0
if pa.len < pb.len : quit sb, 0
for i in 0..<pa.len:
  if pa[i].ord() > pb[i].ord(): quit sa,0
  if pa[i].ord() < pb[i].ord(): quit sb,0
