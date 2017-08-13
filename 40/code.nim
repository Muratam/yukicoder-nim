import sequtils,strutils,strscans,algorithm,math,future,macros
template get*():string = stdin.readLine() #.strip()

let
  D = get().parseInt()
  A = get().split().map(parseInt)
var ans = A
for i in countdown(D, 3):
  ans[i-2] += ans[i]
  ans[i] = 0

if ans.len >= 3 and ans[2] != 0:
  echo 2
  echo ans[0..2].mapIt($it).join(" ")
elif ans.len >= 2 and ans[1] != 0:
  echo 1
  echo ans[0..1].mapIt($it).join(" ")
else:
  echo 0
  echo ans[0]