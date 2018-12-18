import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
let (a,b) = get().split().unpack(2)
# \ 0 1 2 3
# 0 E S S S
# 1 \ S S S
# 2 \ \ E P
# 3 \ \ \ P
if a == "0" and b == "0": echo "E"
elif a == "2" and b == "2": echo "E"
elif a == "0" or b == "0": echo "S"
elif a == "1" or b == "1": echo "S"
else: echo "P"