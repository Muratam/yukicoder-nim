import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

var (a,b,c,d) = get().split().map(parseInt).unpack(4)
# score: a * 100 + b * 50
if d >= 10:
  echo "Impossible"
  quit(0)
# 先に b 全て
var score = 0
var combo = 0
while a > 0 or b > 0:
  let rate = (1 shl (combo div 100))
  if b > 0:
    b -= 1
    score += 50 * rate
  else:
    a -= 1
    score += 100 * rate
  combo += 1
echo "Possible"
echo score