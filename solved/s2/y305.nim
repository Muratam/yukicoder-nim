import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops

template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

proc argMax[T](arr:seq[T]):int =
  result = 0
  var val = arr[0]
  for i,a in arr:
    if a <= val: continue
    val = a
    result = i

var S = toSeq("0000000000".items).mapIt(it.ord - '0'.ord)
proc check() : int =
  echo S.join("")
  let (X,L) = get().split().unpack(2)
  let x = X.parseInt()
  if x == 10: quit(0)
  return x
for i in 0..<100:
  var oks = newSeq[int](10)
  for j in 0..9:
    S[i] = j
    oks[j] = check()
  S[i] = oks.argMax()
