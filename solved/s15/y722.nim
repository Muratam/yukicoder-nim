import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (a,b) = get().split().map(parseInt).unpack(2)
# [d]00,[d]000,...
proc isCalc():bool =
  if a.abs < 100 or b.abs < 100: return true
  if ($a.abs)[1..^1].allIt(it == '0') and
     ($b.abs)[1..^1].allIt(it == '0') : return false
  return true
if isCalc():
  let res = a * b
  if res.abs > 99999999 : echo "E"
  else: echo res
else:
  echo a * b div 10