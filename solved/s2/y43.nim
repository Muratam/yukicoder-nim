import sequtils,strutils,algorithm

let n = stdin.readLine().parseInt()
var S = newSeqWith(n,stdin.readLine)
proc rank(S:seq[string]) : int =
  let SI = toSeq(0..<n).mapIt((i:it,win:S[it].count('o')))
  let I = SI.sortedByIt(-it.win)
  if I[0].i == 0 : return 1
  var rank = 1
  for i in 1..<n:
    if I[i].win != I[i-1].win : rank += 1
    if I[i].i == 0 : return rank


proc emb(S:seq[string],yets:seq[tuple[x,y:int]]) : seq[string] =
  if yets.len == 0 : return S
  let yet = yets[0]
  var SA = S
  SA[yet.x][yet.y] = 'o'
  SA[yet.y][yet.x] = 'x'
  SA = SA.emb(yets[1..^1])
  var SB = S
  SB[yet.x][yet.y] = 'x'
  SB[yet.y][yet.x] = 'o'
  SB = SB.emb(yets[1..^1])
  if SA.rank < SB.rank : return SA
  return SB
var yets = newSeq[tuple[x,y:int]]()
for x in 0..<n:
  for y in (x+1)..<n:
    if S[x][y] == '-': yets &= (x,y)

echo S.emb(yets).rank()
