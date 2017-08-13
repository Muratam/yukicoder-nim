import sequtils,strutils,strscans,algorithm,math,future,macros
template get*():string = stdin.readLine() #.strip()
macro unpack*(rhs: seq,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `rhs`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
let
  # N<100, D<10^9, T<10^9
  (N,D,T) = get().split().map(parseInt).unpack(3)
  X = get().split().map(parseInt)
  XLR = X.mapIt((L:it-D*T,M:it,R:it+D*T))
var ans = 0
for i,x in XLR:
  # other ameba range
  var amebas = newSeq[tuple[L,R:int]]()
  for y in XLR[0..<i]:
    if abs(x.M - y.M) mod D == 0 and
      (x.R >= y.L and y.R >= x.L) :
      amebas &= (max(y.L,x.L), min(y.R,x.R))
  # flatten
  const invalid = (1,-1)
  for ai,a in amebas:
    for bi,b in amebas[0..<ai]:
      if a.R >= b.L and b.R >= a.L and b != invalid:
        amebas[ai] = (min(a.L,b.L), max(a.R,b.R))
        amebas[bi] = invalid
  amebas = amebas.filterIt(it != invalid)
  # sub other ranges
  var seg = 2 * T + 1
  for a in amebas:
    seg -= (a.R - a.L) div D + 1
  ans += seg
echo ans
