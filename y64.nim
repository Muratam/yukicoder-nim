import sequtils,strutils,macros
macro unpack*(rhs: seq,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `rhs`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
let
  (F0,F1,N) = stdin.readLine.split.map(parseInt).unpack(3)
  F = @[F0,F1,F0 xor F1]
echo F[N mod 3]