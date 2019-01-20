import sequtils,strutils,strscans,algorithm,math,future,macros
macro unpack*(rhs: seq,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `rhs`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template get*():string = stdin.readLine() #.strip()

let (D,P) = get().split().map(parseInt).unpack(2)
echo D * (100 + P) div 100