import sequtils,strutils,strscans,algorithm,math,future,macros
import sets,queues,tables,nre,pegs

let words = stdin.readLine().findAll(re"\d+|\+|\*")
#let words = stdin.readLine().findAll(peg"\d+ / '+' / '*'")
var
  ans = 0
  isPlus = true
for w in words:
  if w == "*" : isPlus = true
  elif w == "+" : isPlus = false
  elif isPlus: ans += w.parseInt()
  else : ans *= w.parseInt()
echo ans