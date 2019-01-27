import sequtils,algorithm,tables
template times*(n:int,body) = (for _ in 0..<n: body)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

var V = initTable[char,char]()
proc scanCode(n:int) =
  n.times:
    var pre = getchar_unlocked()
    while true:
      let k = getchar_unlocked()
      if k < 'A' or k > 'Z' :
        if pre notin V : V[pre] = pre
        break
      if k notin V or V[pre] == pre : V[pre] = k
      pre = k

scan().scanCode()
scan().scanCode()
if toSeq(V.pairs).filterIt(it[0] == it[1]).len >= 2: quit "-1",0
proc interpret(start:char):string =
  result = ""
  var i = start
  while true:
    result &= i
    if i == V[i] : return
    i = V[i]
var answers = newSeq[string]()
for k in V.keys: answers &= interpret(k)
echo answers.sortedByIt(-it.len)[0]
