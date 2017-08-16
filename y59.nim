import sequtils,strutils,algorithm,math,future,macros
# import sets,queues,tables,nre,pegs,rationals
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template `max=`*(x,y:typed):void = x = max(x,y)
template `min=`*(x,y:typed):void = x = min(x,y)

############## Binary Indexed Tree #####################
type BinaryIndexedTree*[CNT:static[int],T] = object
    data: array[CNT,T]
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
############## Binary Indexed Tree #####################


proc getchar():char {. importc:"getchar",header: "<stdio.h>" .}
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
template scan1[T](thread_safe:bool): T =
  var minus = false
  var result : T = 0
  while true:
    when thread_safe:(var k = getchar())
    else:( var k = getchar_unlocked())
    if k == '-' : minus = true
    elif k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord
  if minus: result *= -1
  result
macro scanints(cnt:static[int]): auto =
  if cnt == 1:(result = (quote do: scan1[int](false)))
  else:(result = nnkBracket.newNimNode;for i in 0..<cnt:(result.add(quote do: scan1[int](false))))

let
  (N,K) = get().split().map(parseInt).unpack(2) # ~1e6
  W = newSeqWith(N,get().parseInt()) # ~1e6
var cargo : BinaryIndexedTree[100_0001,int]
var last = 0
for w in W:
  if w > 0:
    if last - cargo[w-1] >= K: continue # W以上の荷物がK個以上
    cargo.inc w, 1
    last += 1
  else:
    if cargo[-w-1] == cargo[-w] : continue # 荷物が無い
    cargo.inc -w,-1
    last -= 1
echo last