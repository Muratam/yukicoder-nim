# ロリハ
# 構築 O(|S|) / 部分文字列検索 O(1)
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
proc hash(self:RollingHash,l,r:int):(int,int) = # [l,r)
  ((self.AP[r-l] * self.A[l] - self.A[r] + self.modA) mod self.modA,
  (self.BP[r-l] * self.B[l] - self.B[r] + self.modB) mod self.modB)
  # 67800 と 678 は 67800 == 678 * 100 で得られる
