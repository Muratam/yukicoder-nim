import sequtils
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

type BinaryIndexedTree*[CNT:static[int],T] = object
  data: array[CNT,T]
template useBinaryIndexedTree =
  proc `[]`*[CNT,T](bit:BinaryIndexedTree[CNT,T],i:int): T =
    if i == 0 : return bit.data[0]
    result = 0 # 000111122[2]2223333
    var index = i
    while index > 0:
      result += bit.data[index]
      index -= index and -index # 0111 -> 0110 -> 0100
  proc inc*[CNT,T](bit:var BinaryIndexedTree[CNT,T],i:int,val:T) =
    var index = i
    while index < bit.data.len():
      bit.data[index] += val
      index += index and -index # 001101 -> 001110 -> 010001
  proc `$`*[CNT,T](bit:BinaryIndexedTree[CNT,T]): string =
    result = "["
    for i in 0..bit.data.high: result &= $(bit[i]) & ", "
    return result[0..result.len()-2] & "]"
  proc len*[CNT,T](bit:BinaryIndexedTree[CNT,T]): int = bit.data.len()
useBinaryIndexedTree()

let n = scan()
let k = scan()
var cargo : BinaryIndexedTree[100_0001,int]
var last = 0
n.times:
  let w = scan()
  if w > 0:
    if last - cargo[w-1] >= k: continue # W以上の荷物がK個以上
    cargo.inc w, 1
    last += 1
  else:
    if cargo[-w-1] == cargo[-w] : continue # 荷物が無い
    cargo.inc -w,-1
    last -= 1
echo last