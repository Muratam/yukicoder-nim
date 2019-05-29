import sequtils,strutils,algorithm,math,future,macros
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)
proc `*`(str:string,t:int):string =
  result = "";for i in 0..<t:(result &= str)

let
  WHC = get().split()
  (W,H) = WHC[0..^2].map(parseInt).unpack(2)
var isB = WHC[2] == "B"
H.times:
  if isB : echo "BW"*(W div 2) & "B"*(W mod 2)
  else: echo "WB"*(W div 2)  & "W"*(W mod 2)
  isB = not isB