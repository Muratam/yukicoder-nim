type SuffixArray = ref object
  S : string
  n : int
  SA : seq[int]
  LCP : seq[int]
# 多分n (log n)^2
import sequtils,algorithm
import times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")

proc newSuffixArray(S:string):SuffixArray =
  new(result)
  result.S = S
  let n = S.len
  result.n = n
  # SA
  var G = newSeq[int](n+1)
  for i in 0..<n: G[i] = S[i].int
  G[n] = -1
  proc SAComp(h:int):proc(x,y:int):int =
    return proc(x,y:int):int =
      if x == y : return 0
      if G[x] == G[y] : return G[x+h] - G[y+h]
      return G[x] - G[y]
  # ここのソートに N*logN*logN かかる
  result.SA = toSeq(0..n)
  result.SA.sort(0.SAComp)
  var B = newSeq[int](n+1)
  var h = 1
  while B[n] != n:
    let comp = h.SAComp
    result.SA.sort(comp)
    for i in 0..<n:
      B[i+1] = B[i] + (if comp(result.SA[i],result.SA[i+1]) < 0 : 1 else: 0)
    for i in 0..n: G[result.SA[i]] = B[i]
    h *= 2
  # LCP (最長共通接頭辞)
  # SA格納順に隣同士の最長共通接頭辞の長さ
  # kasai's algorithm で O(N) にできる
  result.LCP = newSeq[int](n+1)
  h = 0
  for i in 0..n: B[result.SA[i]] = i
  for i in 0..n:
    if B[i] > 0 :
      var j = result.SA[B[i]-1]
      while j + h < n and i + h < n and S[j+h] == S[i+h]: h += 1
      result.LCP[B[i]] = h
    if h > 0 : h -= 1
  result.LCP[0] = -1


# 検索はO(MlogN)
iterator find(self:SuffixArray,target:string): int =
  var a = -1
  var b = self.n + 1
  while a + 1 < b:
    let m = (a + b) shr 1
    let start = self.SA[m]
    if cmp(self.S[start..<self.S.len.min(start+target.len)],target) < 0 : a = m
    else : b = m
  var already = false
  while b <= self.n :
    let start = self.SA[b]
    if already: # 既にマッチしているので更にもっとマッチするかどうか見るだけで良い
      if self.LCP[b] >= target.len: yield start
      else: break
    elif cmp(self.S[start..<self.S.len.min(start+target.len)],target) == 0 :
      yield start
      already = true
    else: break
    b += 1
proc findAll(self:SuffixArray,target:string):seq[int] = toSeq(self.find(target)).reversed()
proc findOne(self:SuffixArray,target:string): int =
  for i in self.find(target): return i
  return -1
proc getSuffixString(S:string,index:int) : string = S[index..^1]
proc getSuffixString(self:SuffixArray,index:int) : string = self.S[self.SA[index]..^1]
proc getAllSuffixString(self:SuffixArray):seq[string] =
  result = newSeq[string](self.SA.len)
  for i in 0..<self.SA.len:
    result[i] = self.getSuffixString(i)


import strutils

when isMainModule:
  import unittest
  test "Suffix Array":
    block:
      let S = "abc".repeat(100000)
      let SA = S.newSuffixArray()
      let target = "abc".repeat(50000)
      check: SA.findAll(target).len == 50001
    block:
      let bananaStr = "banana"
      let banana = bananaStr.newSuffixArray()
      check: banana.SA == @[6, 5, 3, 1, 0, 4, 2]
      check: banana.LCP == @[-1, 0, 1, 3, 0, 0, 2]
      check: banana.getAllSuffixString() == @["","a","ana","anana","banana","na","nana"]
      check: banana.findAll("an") == @[1,3]
      check: banana.findAll("an").mapIt(bananaStr.getSuffixString(it)) == @["anana","ana"]
