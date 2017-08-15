import sequtils,strutils,math
let K = stdin.readLine().parseInt()
var E = newSeqWith(K+6,0.0)
for x in countdown(K-1,0):
  E[x] = E[x+1..x+6].sum()/6.0 + 1.0
echo E[0]