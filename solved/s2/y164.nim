import sequtils
template times*(n:int,body) = (for _ in 0..<n: body)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    result = 10 * result + k.ord - '0'.ord
proc scanAscii(S:seq[int],rank:int) : tuple[n:int,ok:bool]=
  var n = 0
  for s in S:
    if s >= rank : return (-1,false)
    n = n * rank + s
  return (n,true)
let n = scan()
var ans = int.high
n.times:
  let S = toSeq(stdin.readLine().items).mapIt:
    if '0' <= it and it <= '9' : it.ord - '0'.ord
    else: it.ord - 'A'.ord + 10
  for rank in 2..36:
    let (n,ok) = S.scanAscii(rank)
    if ok : ans .min= n
echo ans