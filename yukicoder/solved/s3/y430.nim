import sequtils,algorithm
template times*(n:int,body) = (for _ in 0..<n: body)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

template useRollingHash() = # 構築 O(|S|) / 部分文字列検索 O(1)
  type RollingHash = ref object
    modA,modB : int
    baseA,baseB : int
    A,B: seq[int]  # baseA 進数表示
    AP,BP: seq[int] # pow(baseA,n)
  proc initRollingHash(
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
  proc hash(self:RollingHash,l,r:int):(int,int) = # [l,r)
    ((self.AP[r-l] * self.A[l] - self.A[r] + self.modA) mod self.modA,
    (self.BP[r-l] * self.B[l] - self.B[r] + self.modB) mod self.modB)
    # 67800 と 678 は 67800 == 678 * 100 で得られる
useRollingHash()

let S = stdin.readLine()
let m = scan()
let RH = S.initRollingHash()
var H = newSeqWith(11,newSeq[(int,int)]())
for i in 1..10:
  for j in 0..S.len-i:
    H[i] &= RH.hash(j,j+i)
for i in 1..10: H[i].sort(cmp)
var ans = 0
m.times:
  let S2 = stdin.readLine()
  let h = S2.initRollingHash().hash(0,S2.len)
  ans += H[S2.len].upperBound(h) - H[S2.len].lowerBound(h)
echo ans