import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues,times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord

type RollingHash = ref object
  modA,modB : int
  baseA,baseB : int
  A,B: seq[int]  # baseA 進数表示
  AP,BP: seq[int] # pow(baseA,n)
proc newRollingHash(
    S:string, baseA:int=17, baseB:int=19,
    modA:int=1_0000_0000_7.int, modB:int=1_0000_0000_9.int) : RollingHash =
  new(result)
  result.baseA = baseA
  result.baseB = baseB
  result.modA = modA
  result.modB = modB
  result.A = newSeq[int](S.len + 1)
  result.B = newSeq[int](S.len + 1)
  result.AP = newSeq[int](S.len + 1)
  result.BP = newSeq[int](S.len + 1)
  result.AP[0] = 1
  result.BP[0] = 1
  for i in 0..<S.len: result.A[i+1] = (result.A[i] * baseA + S[i].ord) mod modA
  for i in 0..<S.len: result.B[i+1] = (result.B[i] * baseB + S[i].ord) mod modB
  for i in 0..<S.len: result.AP[i+1] = (result.AP[i] * baseA) mod modA
  for i in 0..<S.len: result.BP[i+1] = (result.BP[i] * baseB) mod modB
proc hash(self:RollingHash,slice:Slice[int]):(int,int) = # [l,r)
  let l = slice.a
  let r = slice.b + 1
  return ((self.AP[r-l] * self.A[l] - self.A[r] + self.modA) mod self.modA,
  (self.BP[r-l] * self.B[l] - self.B[r] + self.modB) mod self.modB)
  # 67800 と 678 は 67800 == 678 * 100 で得られる


discard scan()
let S = stdin.readLine()
var RH = newRollingHash(S)
for length in (S.len div 2).countdown(1):
  var pos = initTable[(int,int),int]()
  for i in 0..S.len-length:
    var h = RH.hash(i..<i+length)
    if h in pos:
      let pre = pos[h]
      if i - pre >= length:
        echo length
        quit 0
    else:
      pos[h] = i
echo 0
