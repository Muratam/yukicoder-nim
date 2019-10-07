# ロリハ
# 構築 O(|S|) / 部分文字列検索 O(1)
type RollingHash* = ref object
  modA,modB : int
  baseA,baseB : int
  A,B: seq[int]  # baseA 進数表示
  AP,BP: seq[int] # pow(baseA,n)
type RollingHashed* = (int,int)
proc newRollingHash*(
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
proc hash*(self:RollingHash,slice:Slice[int]): RollingHashed =
  let l = slice.a
  let r = slice.b + 1
  return ((self.AP[r-l] * self.A[l] - self.A[r] + self.modA) mod self.modA,
  (self.BP[r-l] * self.B[l] - self.B[r] + self.modB) mod self.modB)
  # 67800 と 678 は 67800 == 678 * 100 で得られる



when isMainModule:
  import unittest
  test "rolling hash":
    block:
      const str = "iikanji iikamo"
      var RH = newRollingHash(str)
      check:RH.hash(0..<4) == RH.hash(8..<12)
      check:RH.hash(0..0) == RH.hash(1..1)
      check:RH.hash(0..10) != RH.hash(5..9)
    block:
      const str = "1234567890-^qwertyuiop@[asdfghjkl;:zxcvbnm,./_"
      var RH = newRollingHash(str)
      for i1 in 0..<str.len:
        for i2 in i1..<str.len:
          for j1 in 0..<str.len:
            for j2 in j1..<str.len:
              if i1 == j1 and i2 == j2 : continue
              check: RH.hash(i1..i2) != RH.hash(j1..j2)
