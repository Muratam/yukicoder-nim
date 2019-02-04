import sequtils,strutils,algorithm,math,sugar,macros
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template `max=`*(x,y:typed):void = x = max(x,y)
template `min=`*(x,y:typed):void = x = min(x,y)

template useBinaryIndexedTree() = # 部分和検索 / 更新 O(log(N))
  type BinaryIndexedTree[T] = ref object
    data: seq[T] # 引数以下の部分和(Fenwick Tree)
  proc initBinaryIndexedTree[T](n:int):BinaryIndexedTree[T] =
    new(result)
    result.data = newSeq[T](n)
  proc len[T](self:BinaryIndexedTree[T]): int = self.data.len()
  proc update[T](self:var BinaryIndexedTree[T],i:int,val:T) =
    var i = i
    while i < self.len():
      self.data[i] += val
      i = i or (i + 1)
  proc `[]`[T](self:BinaryIndexedTree[T],i:int): T =
    var i = i
    while i >= 0:
      result += self.data[i]
      i = (i and (i + 1)) - 1
  proc `$`[T](self:BinaryIndexedTree[T]): string =
    result = "["
    for i in 0..<self.len.min(100): result &= $(self[i]) & ", "
    return result[0..result.len()-2] & (if self.len > 100 : " ...]" else: "]")
useBinaryIndexedTree()
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

var last = 0
let n = scan()
let k = scan()
var cargo =  initBinaryIndexedTree[int](100_0001)
n.times:
  let w = scan()
  if w > 0:
    if last - cargo[w-1] >= k: continue # W以上の荷物がK個以上
    cargo.update w, 1
    last += 1
  else:
    if cargo[-w-1] == cargo[-w] : continue # 荷物が無い
    cargo.update -w,-1
    last -= 1
echo last