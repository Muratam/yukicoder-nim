import sequtils,strutils,strscans,algorithm,math,future,macros
template get*():string = stdin.readLine() #.strip()
macro unpack*(rhs: seq,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `rhs`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
let (L,K) = get().split().map(parseInt).unpack(2)
#echo (2Kn < L <= 2K(n+1) ::=> 2Kn)
echo(K*((L-1) div (2*K)))
