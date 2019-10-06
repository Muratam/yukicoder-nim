# SA-IS :: O(N) で Suffix Array を構築
# 文字列検索は O(MlogN) でできる.
# 「追加の更新が発生するprefix検索」はTrie木を使うしかないが,
# SA-IS は ほぼこれ https://blog.knshnb.com/posts/sa-is/
import sequtils
type SuffixArray* = ref object
  S* : string
  SA*: seq[int]
  LCP*: seq[int]
proc SAIS(inputString:string) : seq[int] =
  proc SAISImpl(S:seq[int], k:int):seq[int] =
    # https://blog.knshnb.com/posts/sa-is/
    let n = S.len
    # [1..255] までのbyte文字しかでないはず
    # 1. S, L, LMS
    var isS = newSeq[bool](n)
    isS[n-1] = true
    var isLMS = newSeq[bool](n)
    var LMSS = newSeq[int]()
    for i in (n-2).countdown(0):
      isS[i] = S[i] < S[i+1] or (S[i] == S[i+1] and isS[i + 1])
    for i in 0..<n:
      if isS[i] and (i == 0 or not isS[i-1]):
        isLMS[i] = true
        LMSS.add i
    # 2. induced sort
    proc inducedSort(LMSS:var seq[int]):seq[int] =
      var buckets = newSeq[int](n)
      var chars = newSeq[int](k+1)
      for c in S: chars[c.int+1] += 1
      for i in 0..<k: chars[i + 1] += chars[i]
      var count = newSeq[int](k)
      for i in (LMSS.len - 1).countdown(0):
        let c = S[LMSS[i]].int
        buckets[chars[c+1]-1-count[c]] = LMSS[i]
        count[c] += 1
      count = newSeq[int](k)
      for i in 0..<n:
        if buckets[i] == 0 or isS[buckets[i]-1] : continue
        let c = S[buckets[i] - 1].int
        buckets[chars[c] + count[c]] = buckets[i] - 1
        count[c] += 1
      count = newSeq[int](k)
      for i in (n-1).countdown(0):
        if buckets[i] == 0 or not isS[buckets[i]-1] : continue
        let c = S[buckets[i] - 1].int
        buckets[chars[c+1] - 1 - count[c]] = buckets[i] - 1
        count[c] += 1
      return buckets

    var pseudoSA = LMSS.inducedSort()
    var orderedLMSS = newSeq[int](LMSS.len)
    var index = 0
    for x in pseudoSA:
      if isLMS[x] :
        orderedLMSS[index] = x
        index += 1
    pseudoSA[orderedLMSS[0]] = 0
    var rank = 0
    if orderedLMSS.len > 1:
      rank += 1
      pseudoSA[orderedLMSS[1]] = rank
    for i in 1..<orderedLMSS.len - 1:
      var isDiff = false
      for j in 0..<n:
        let p = orderedLMSS[i] + j
        let q = orderedLMSS[i + 1] + j
        if S[p] != S[q] or isLMS[p] != isLMS[q] :
          isDiff = true
          break
        if j > 0 and isLMS[p] : break
      if isDiff: rank += 1
      pseudoSA[orderedLMSS[i+1]] = rank
    var newS = newSeq[int](LMSS.len())
    index = 0
    for i in 0..<n:
      if isLMS[i]:
        newS[index] = pseudoSA[i]
        index += 1
    # 3 再帰でnew_strのsuffix arrayを求める
    var LMSSA = newSeq[int]()
    if rank + 1 == LMSS.len:
      LMSSA = orderedLMSS
    else:
      LMSSA = SAISImpl(newS,rank + 1)
      for i in 0..<LMSSA.len:
        LMSSA[i] = LMSS[LMSSA[i]]
    return LMSSA.inducedSort()
  # 終端を 0 にして全てのchar文字を解釈可能に
  var G = newSeq[int](inputString.len + 1)
  for i in 0..<inputString.len:
    G[i] = inputString[i].int + 1
  return SAISImpl(G,260)
proc newSuffixArray*(S:string):SuffixArray =
  new(result)
  result.S = S
  result.SA = S.SAIS()
  let n = S.len
  # LCP (最長共通接頭辞)
  # SA格納順に隣同士の最長共通接頭辞の長さ
  # kasai's algorithm で O(N) にできる
  result.LCP = newSeq[int](n+1)
  var h = 0
  var B = newSeq[int](n+1)
  for i in 0..n: B[result.SA[i]] = i
  for i in 0..n:
    if B[i] > 0 :
      var j = result.SA[B[i]-1]
      while j + h < n and i + h < n and S[j+h] == S[i+h]: h += 1
      result.LCP[B[i]] = h
    if h > 0 : h -= 1
  result.LCP[0] = -1
# その文字列の出現位置
iterator findIndex*(self:SuffixArray,target:string): int =
  var a = -1
  var b = self.S.len + 1
  while a + 1 < b:
    let m = (a + b) shr 1
    let start = self.SA[m]
    if cmp(self.S[start..<self.S.len.min(start+target.len)],target) < 0 : a = m
    else : b = m
  var already = false
  while b <= self.S.len :
    let start = self.SA[b]
    if already: # 既にマッチしているので更にもっとマッチするかどうか見るだけで良い
      if self.LCP[b] >= target.len: yield start
      else: break
    elif cmp(self.S[start..<self.S.len.min(start+target.len)],target) == 0 :
      yield start
      already = true
    else: break
    b += 1
proc findAllIndex*(self:SuffixArray,target:string):seq[int] =
  toSeq(self.findIndex(target))
proc findOneIndex*(self:SuffixArray,target:string): int =
  for i in self.findIndex(target): return i
  return -1
# その単語の出現個数.
# TODO: もっと高速化できる.
# abcab*** で検索すると [abcab,abcab\0,...abcab\ff\ff\ff\ff] までが対象となるので,
# upperBound / lowerBound 関数を作り、 at("abcac") - at("abcab") すれば出せる
proc getCount*(self:SuffixArray,target:string): int =
  for _ in self.findIndex(target): result += 1
# 文字列がそのまま欲しいとき用. 文字列なので処理時間に注意！
proc getString*(S:string,index:int) : string = S[index..^1]
proc getString*(self:SuffixArray,index:int) : string = self.S[index..^1]
proc getAllSuffixArrayString*(self:SuffixArray):seq[string] =
  result = newSeq[string](self.SA.len)
  for i in 0..<self.SA.len:
    result[i] = self.getString(self.SA[i])
iterator findMatchedString*(self:SuffixArray,target:string): string =
  for i in self.findIndex(target):
    yield self.getString(i)
proc findAllMatchedString*(self:SuffixArray,target:string):seq[string] =
  toSeq(self.findMatchedString(target))
proc findOneMatchedString*(self:SuffixArray,target:string):string =
  for s in self.findMatchedString(target): return s
  return ""



when isMainModule:
  import unittest
  import strutils
  import times
  template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
  test "Suffix Array":
    block: # 46ms
      let S = "abc".repeat(100000)
      let SA = S.newSuffixArray()
      let target = "abc".repeat(50000)
      check: SA.findAllIndex(target).len == 50001
      check: SA.getCount(target) == 50001
    block:
      let bananaStr = "banana"
      let banana = bananaStr.newSuffixArray()
      check: banana.SA == @[6, 5, 3, 1, 0, 4, 2]
      check: banana.LCP == @[-1, 0, 1, 3, 0, 0, 2]
      check: banana.getAllSuffixArrayString() == @["","a","ana","anana","banana","na","nana"]
      check: banana.findAllIndex("an") == @[3,1]
      check: banana.findAllIndex("an").mapIt(bananaStr.getString(it)) == @["ana","anana"]
      check: banana.findOneIndex("an") == 3
      check: banana.getCount("an") == 2
      check: banana.findAllMatchedString("an") == @["ana", "anana"]
      check: banana.findOneMatchedString("an") == "ana"
