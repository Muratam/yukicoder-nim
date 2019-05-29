import sequtils,algorithm,math,tables
import sets,intsets,queues,heapqueue,bitops,strutils
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc check(S:string) : bool =
  const names = ["digi ","petit ","gema ","piyo "]
  const lasts = ["nyo","nyu","gema","pyo"]
  proc isSymbol(c:char) : bool =
    if 'a' <= c and c <= 'z' : return false
    if '0' <= c and c <= '9' : return false
    if 'A' <= c and c <= 'Z' : return false
    return true
  if S.startsWith("rabi "):
    return S[5..^1].anyIt(not it.isSymbol())
  for i,name in names:
    if not S.startsWith(name): continue
    let lower = S[name.len..^1].toLower()
    if lower.endsWith(lasts[i]) : return true
    for j in 1..3:
      if lower.len - j - lasts[i].len < 0 : continue
      let llast = lower[^(j+(lasts[i].len))..^(j+1)]
      if llast != lasts[i]: continue
      if lower[^j..^1].allIt(it.isSymbol()) : return true
  return false

var line = ""
while true:
  let k = getchar_unlocked()
  if k == '\n':
    if line.check(): echo "CORRECT (maybe)"
    else: echo "WRONG!"
    line = ""
    continue
  if k.ord < 32 or k.ord > 126: break
  line &= k