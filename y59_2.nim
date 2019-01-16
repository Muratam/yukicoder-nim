import sequtils,strutils,algorithm,math,sugar,macros
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template `max=`*(x,y:typed):void = x = max(x,y)
template `min=`*(x,y:typed):void = x = min(x,y)

type BinaryIndexedTree*[CNT:static[int],T] = object
  data: array[CNT,T]
proc `[]`*[CNT,T](bit:BinaryIndexedTree[CNT,T],i:int): T =
  if i == 0 : return bit.data[0]
  result = 0
  var index = i
  while index > 0:
    result += bit.data[index]
    index -= index and -index
proc add*[CNT,T](bit:var BinaryIndexedTree[CNT,T],i:int,val:T) =
  var index = i
  while index < bit.data.len():
    bit.data[index] += val
    index += index and -index

template useScan =
  proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
  proc scan(): int =
    result = 0
    var minus = false
    while true:
      var k = getchar_unlocked()
      if k == '-' : minus = true
      elif k < '0' or k > '9': break
      else: result = 10 * result + k.ord - '0'.ord
    if minus: result *= -1

useScan()

var cargo : BinaryIndexedTree[100_0001,int]
var last = 0
let n = scan()
let k = scan()
n.times:
  let w = scan()
  if w > 0:
    if last - cargo[w-1] >= k: continue # W以上の荷物がK個以上
    cargo.add(w, 1)
    last += 1
  else:
    if cargo[-w-1] == cargo[-w] : continue # 荷物が無い
    cargo.add(-w,-1)
    last -= 1
echo last