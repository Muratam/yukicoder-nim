import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
proc toCountSeq[T](x:seq[T]) : seq[tuple[k:T,v:int]] = toSeq(x.toCountTable().pairs)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord

let n = scan() # 50
let m = scan() # 1000
let AB = newSeqWith(m,(scan(),scan()))
var mat = newSeqWith(n,newSeq[bool](n))
for ab in AB:
  let (a,b) = ab
  mat[a][b] = true
  mat[b][a] = true
var ans = 0
for i in 0..<m:
  let (a,b) = AB[i]
  for j in (i+1)..<m:
    let (c,d) = AB[j]
    if a == c or a == d or b == c or b == d: continue
    if mat[a][c] and mat[b][d] and not mat[a][d] and not mat[b][c] : ans += 1
    elif not mat[a][c] and not mat[b][d] and mat[a][d] and mat[b][c] : ans += 1
echo ans div 2