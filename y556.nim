import sequtils,algorithm,math,tables,macros
import sets,intsets,queues,heapqueue,bitops,strutils
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
const maxN = 10010

template useUnionFind =
  var parent : array[maxN,int32]
  proc root[T](x:T): T =
    if parent[x] == x: return x
    parent[x] = root(parent[x])
    return parent[x]
  proc initUnionFind(size:int) =
    for i in 0.int32..<size.int32: parent[i] = i
  # proc same[T](self:var UnionFind[T],x,y:T) : bool = self.root(x) == self.root(y)
  proc unite[T](sx,sy:T) =
    let rx = root(sx)
    let ry = root(sy)
    parent[rx] = ry

useUnionFind()
proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int32 =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10.int32 * result + k.ord.int32 - '0'.ord.int32

proc printInt(a0:int32) =
  template div10(a:int32) : int32 = cast[int32]((0x1999999A * cast[int64](a)) shr 32)
  template put(n:int32) = putchar_unlocked("0123456789"[n])

  proc getPrintIntNimCode(n,maxA:static[int32]):string =
    result = "if a0 < " & $maxA & ":\n"
    for i in 1..n: result &= "  let a" & $i & " = a" & $(i-1) & ".div10\n"
    result &= "  put(a" & $n & ")\n"
    for i in n.countdown(1): result &= "  put(a" & $(i-1) & "-a" & $i & "*10)\n"
    result &= "  return"
  macro eval(s:static[string]): auto = parseStmt(s)
  eval(getPrintIntNimCode(0,10))
  eval(getPrintIntNimCode(1,100))
  eval(getPrintIntNimCode(2,1000))
  eval(getPrintIntNimCode(3,10000))
  eval(getPrintIntNimCode(4,100000))
  eval(getPrintIntNimCode(5,1000000))
  eval(getPrintIntNimCode(6,10000000))
  eval(getPrintIntNimCode(7,100000000))
  eval(getPrintIntNimCode(8,1000000000))

let n = scan()
initUnionFind(n+1)
var cnts : array[maxN,int32]
for i in 0..n: cnts[i] = 1
scan().times:
  let a = scan()
  let b = scan()
  let ra = root(a)
  let rb = root(b)
  if ra == rb : continue
  var aWin = false
  if cnts[ra] != cnts[rb] : aWin = cnts[ra] > cnts[rb]
  else : aWin = ra < rb
  if aWin:
    unite(rb,ra)
    cnts[ra] += cnts[rb]
  else:
    unite(ra,rb)
    cnts[rb] += cnts[ra]
for i in 1..n:
  root(i).printInt()
  putchar_unlocked('\n')
