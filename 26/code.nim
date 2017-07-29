import sequtils,strutils,strscans,algorithm,math,future,sets,macros
template get():string = stdin.readLine()
template times(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template REP(i:untyped,n:int,body:untyped):untyped =
  block:(var i = 0; while i < n:( body; i += 1))

###################################################################
var
  A = newSeq[bool](4)
let
  N = get().parseInt
  M = get().parseInt
A[N] = true
M.times:
  var P,Q = 0
  (P,Q) = get().split().map(parseInt)
  (A[P],A[Q]) = (A[Q],A[P])
for i in 1..3:
  if A[i] : echo i