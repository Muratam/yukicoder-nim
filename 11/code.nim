import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables
template get():string = stdin.readLine()
template times(n:int,body:untyped): untyped = (for _ in 0..<n: body)

let
  W = get().parseInt
  H = get().parseInt
  N = get().parseInt
  # let  包除原理
  #   cards = newSeqWith(N,get().split().map(parseInt))
  #   ws = cards.mapIt(it[0]).deduplicate().len()
  #   hs = cards.mapIt(it[1]).deduplicate().len()
  # echo W*H - (W-ws)*(H-hs) - N
  # ソートしたと考えればよい
  # 1 2 x 4 x x x x x x
  # x x 3 x x x x x x x
  # x x x x . . . . . .
  # x x x x . . . . . .
var
  cards = newSeq[tuple[x:int,y:int]](0)
  res = 0
  w_left = W
  h_left = H
N.times:
  var x,y = 0
  (x,y) = get().split().map(parseInt)
  let
    x_new = cards.allIt(it.x != x)
    y_new = cards.allIt(it.y != y)
  if not (x_new and y_new): res -= 1 # 被り
  if x_new: w_left -= 1
  if y_new: h_left -= 1
  if x_new: res += h_left
  if y_new: res += w_left
  cards.add((x,y))
echo res
# 1 x 5 x x
# x . x . .
# x x 2 x x
# x . x . .
# 4 x 3 x x
# (4 + 4) + (3 + 3) + (3 + 0 - 1) + (0 + 0 - 1)