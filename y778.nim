import sequtils
import times
template stopwatch(body) = (let t1 = cpuTime();body;echo "TIME:",(cpuTime() - t1) * 1000,"ms")
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

type BinaryIndexedTree*[CNT:static[int],T] = object
  data: array[CNT,T] # 引数以下の部分和(Fenwick Tree)
proc len*[CNT,T](bit:BinaryIndexedTree[CNT,T]): int = bit.data.len()
proc update*[CNT,T](bit:var BinaryIndexedTree[CNT,T],i:int,val:T) =
  var i = i
  while i < bit.len():
    bit.data[i] += val
    i = i or (i + 1)
proc `[]`*[CNT,T](bit:BinaryIndexedTree[CNT,T],i:int): T =
  var i = i
  while i >= 0:
    result += bit.data[i]
    i = (i and (i + 1)) - 1
proc `$`*[CNT,T](bit:BinaryIndexedTree[CNT,T]): string =
  result = "["
  for i in 0..<bit.len.min(100): result &= $(bit[i]) & ", "
  return result[0..result.len()-2] & (if bit.len > 100 : " ...]" else: "]")

let n = scan()
var E : array[200010,seq[int]]
for i in 1..<n: E[scan()] &= i
var bit : BinaryIndexedTree[200010,int]
proc solve(x:int): int =
  result += bit[x]
  bit.update(x, 1)
  for e in E[x]: result += solve(e)
  bit.update(x, -1)
echo solve(0)