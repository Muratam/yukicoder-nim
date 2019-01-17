import sequtils,strutils,algorithm,math,sugar,macros,strformat
import times
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (a,b,S) = (let t = get().split();(t[0].parseInt(),t[1].parseInt(),t[2][3..^1]))
var diff = 0 # 分 :: .5 -> 30 , .1 -> 6
if '.' notin S: diff = S.parseInt() * 60
else:
  let (sa,sb) = S[1..^1].split(".").map(parseInt).unpack(2)
  diff = sa * 60 + sb * 6
  if S[0] == '-': diff *= -1
diff -= 60 * 9

let f = initTimeFormat("HH:mm")
echo (fmt"{a:02d}:{b:02d}".parse(f) + diff.minutes).format(f)
