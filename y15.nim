import sequtils,algorithm,tables,strutils,times,sugar
template `^`(n:int) : int = (1 shl n)
template stopwatch(body) = (let t1 = cpuTime();body;echo "TIME:",(cpuTime() - t1) * 1000,"ms")
# template stopwatch(body) = body
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

proc cmp(x,y:seq[int]):int =
  for i in 0..<min(x.len,y.len):
    if x[i] != y[i] : return x[i] - y[i]
  return x.len - y.len

var I2 : array[^16,tuple[k,v:int]]
proc buildWithKey(P:seq[int]) =
  for i in (^P.len)..<(^16):I2[i].v = 1e15.int
  I2[0].v = 0
  proc impl(n,x:int) =
    if n == P.len : return
    I2[x or ^n].v = I2[x].v + P[n]
    I2[x or ^n].k = x or ^n
    impl(n+1,x)
    impl(n+1,x or ^n)
  impl(0,0)

proc binaryToIntSeq(n:int):seq[int] =
  result = @[]
  for i in 0..64:
    if (n and ^i) > 0: result &= i + 1
    if n < ^(i+1) : return
var I1 : array[^15,int]
proc build(P:seq[int]) =
  proc impl(n,x:int) = # 1つずつ
    if n == P.len : return
    I1[x or ^n] = I1[x] + P[n]
    impl(n+1,x)
    impl(n+1,x or ^n)
  impl(0,0)
let n = scan()
let s = scan()
let P = newSeqWith(n,scan())
if n == 1: quit "1",0
let n2 = n div 2
let P1 = P[0..<n2]
let P2 = P[n2..<n]
stopwatch:
  P1.build()
  P2.buildWithKey()
  I2.sort((x,y)=>x.v-y.v)
stopwatch:
  var answers = newSeq[int]()
  for x in 0..<(^n2):
    let i1 = I1[x]
    let si = I2.binarySearch(s-i1,proc(K:tuple[k,v:int],V:int):int=K.v-V)
    if si == -1 : continue
    answers &= x or (I2[si].k shl n2)
    for i in (si+1)..<I2.len:
      if I2[i].v + i1 != s: break
      answers &= x or (I2[i].k shl n2)
    for i in (si-1).countdown(0):
      if I2[i].v + i1 != s: break
      answers &= x or (I2[i].k shl n2)
  for ans in answers.map(binaryToIntSeq).sorted(cmp):
    echo ans.mapIt($it).join(" ")