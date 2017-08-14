import sequtils,strutils,strscans,algorithm,math,future,macros
import sets,queues,tables,nre,pegs,rationals
# abc ""=> bc a| ab c=> 末尾に
let S = stdin.readLine()
type Word = tuple[s,left:string]
var
  table = initCountTable[Word]()
  queue = initQueue[Word]()
  ans = 0
proc append(word:Word):void =
  if word in table : return
  queue.add(word)
  table[word] = 1
  if word.left.len == S.len :
    ans += 1

append((S,""))
while queue.len > 0:
  let (s,left) = queue.pop()
  if s.len == 0: continue
  append((s[1..^1],s[0] & left))
  append((s[0..^2],s[^1] & left))
echo ans