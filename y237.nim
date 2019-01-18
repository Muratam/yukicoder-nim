import sequtils,strutils,algorithm,intsets
const F = [3, 5, 17, 257, 65537]
const G = (proc ():seq[int] =
  var G = initIntSet()
  for f in F : G.incl(f)
  var glen = G.card
  while true:
    for g in toSeq(G.items):
      for f in F:
        if g mod f != 0 : G.incl(g * f)
    if G.card == glen : break
    glen = G.card
  return 1 & toSeq(G.items).sorted(cmp)
)()
const H = (proc():seq[int] =
  const INF = 1000000010
  result = @[]
  for i in 0..<100:
    let n = 1 shl i
    if n > INF : break
    for g in G:
      let gn = g * n
      if gn > INF : continue
      result &= g * n
  return result.sorted(cmp)[2..^1]
)()
let n = stdin.readLine().parseInt()
for i,h in H:
  if h <= n : continue
  echo i
  quit 0
echo H.len()