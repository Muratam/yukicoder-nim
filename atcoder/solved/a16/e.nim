import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord

# ロリハ
# 構築 O(|S|) / 部分文字列検索 O(1)
# type RollingHash = ref object
#   modA,modB : int
#   baseA,baseB : int
#   A,B: seq[int]  # baseA 進数表示
#   AP,BP: seq[int] # pow(baseA,n)
# # 17 1_0000_0000_7.int
# # 19 1_0000_0000_9.int

# proc newRollingHash(S:seq[int], baseA:int,modA:int) : RollingHash =
#   new(result)
#   result.baseA = baseA
#   result.modA = modA
#   result.A = newSeq[int](S.len + 1)
#   result.AP = newSeq[int](S.len + 1)
#   result.AP[0] = 1
#   for i in 0..<S.len: result.A[i+1] = (result.A[i] * baseA + S[i]) mod modA
#   for i in 0..<S.len: result.AP[i+1] = (result.AP[i] * baseA) mod modA
# proc hash(self:RollingHash,slice:Slice[int]):int = # [l,r)
#   let l = slice.a
#   let r = slice.b + 1
#   return (self.AP[r-l] * self.A[l] - self.A[r] + self.modA) mod self.modA
#   # 67800 と 678 は 67800 == 678 * 100 で得られる

# RHの数を増やす
const MOD = 1e9.int+7
var n = scan()
var m = scan()
var S = newSeqWith(n,scan())
var T = newSeqWith(m,scan())
if S.len < T.len:
  (S,T) = (T,S)
  (n,m) = (m,n)
var ans = 0
for ti in 0..<T.len:
  for si in 0..<S.len:
    if S[si] != T[ti] : continue
    var now = 0


# let RHS = newRollingHash(S,17,1_0000_0000_7.int)
# let RHT = newRollingHash(T,17,1_0000_0000_7.int)
# var ans = 0
# echo S
# echo T
# for l in 1..S.len:
#   if l > T.len : break
#   var table = newTable[int,int]()
#   for a in 0..<S.len:
#     if a+l > S.len : break
#     echo S[a..<a+l]
#     let h = RHS.hash(a..<a+l)
#     if h in table: table[h] += 1
#     else:table[h] = 1
#   echo table
#   for b in 0..<T.len:
#     if b+l > T.len:break
#     let h = RHT.hash(b..<b+l)
#     echo h
#     if h in table:
#       ans = (ans + table[h]) mod MOD
#       echo "ans:",ans
# # 空集合
# ans = (ans + 1) mod MOD
# echo ans
