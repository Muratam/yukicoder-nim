# SA-IS :: O(S) で Suffix Array を構築
# prefix検索(個数,{上,下}界) O(PlogS)
# Pがかなり長い(P>log|S|)場合,セグツリで O((log|S|)^2+P) に
# 「追加の更新が発生するprefix検索」はTrie木を使うしかないが...
# SAIS実装の参考 : https://blog.knshnb.com/posts/sa-is/
# verify : https://tenka1-2016-final-open.contest.atcoder.jp/submissions/7904612
#        : 文字が巨大な場合,当然だがDP用の配列の確保方法にも気を使ったほうが良い
import sequtils
type SuffixArray* = ref object
  S* : string
  SA*: seq[int]
  LCP*: seq[int]
proc SAIS*(inputString:string) : seq[int] =
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
      result = newSeq[int](n)
      var chars = newSeq[int](k+1)
      for c in S: chars[c+1] += 1
      for i in 0..<k: chars[i + 1] += chars[i]
      var count = newSeq[int](k)
      for i in (LMSS.len - 1).countdown(0):
        let c = S[LMSS[i]].int
        result[chars[c+1]-1-count[c]] = LMSS[i]
        count[c] += 1
      count = newSeq[int](k)
      for i,r in result:
        if r == 0 or isS[r-1] : continue
        let c = S[r-1].int
        result[chars[c] + count[c]] = r - 1
        count[c] += 1
      count = newSeq[int](k)
      for i in (n-1).countdown(0):
        let r = result[i]
        if r == 0 or not isS[r-1] : continue
        let c = S[r - 1].int
        result[chars[c+1] - 1 - count[c]] = r - 1
        count[c] += 1

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
  # LCP (最長共通接頭辞) O(|S|)
  # SA格納順に隣同士の最長共通接頭辞の長さ
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
# O(Plog|S|)
proc lowerBound*(self:SuffixArray,prefix:string): tuple[index:int,isMatched:bool] =
  # i := {S} >= prefix の最小の位置を返却
  var now = -1..self.S.len + 1
  proc compare(start:int):int =
    self.S[start..<self.S.len.min(start+prefix.len)].cmp(prefix)
    #  1 なら prefix の方が短い. または prefix の方が辞書的に前
    # -1 なら S の方が短い. または prefix の方が辞書的に後ろ
    # for i in 0..<prefix.len.min(self.S.len - start):
    #   let si = i + start
    #   let c1 = self.S[si].int
    #   let c2 = prefix[i].int
    #   if c1 == c2 : continue
    #   return c1 - c2
    # if prefix.len > self.S.len - start : return -1
    # return 0
  while now.a + 1 < now.b:
    let m = (now.a + now.b) shr 1
    if compare(self.SA[m]) < 0 : now.a = m
    else : now.b = m
  let found = now.b
  if found >= self.SA.len: return (found,false)
  let isMatched = compare(self.SA[found]) == 0
  return (found,isMatched)
# O(Plog|S|+M) (P:prefix, M:iterateを進めた数)
# prefix にマッチした文字列の最初の位置から順に.辞書順.
iterator findIndex*(self:SuffixArray,prefix:string): int =
  let (startIndex,isMatched) = self.lowerBound(prefix)
  if isMatched:
    yield self.SA[startIndex]
    for found in startIndex+1..self.S.len:
      if self.LCP[found] < prefix.len: break
      yield self.SA[found]
proc findAllIndex*(self:SuffixArray,prefix:string):seq[int] =
  toSeq(self.findIndex(prefix))
# その単語の出現個数. O(Plog|S|)
proc getCount*(self:SuffixArray,prefix:string): int =
  if prefix.len == 0: # 全部にマッチしますが...
    return self.S.len + 1
  if prefix[^1].ord == 255: # 0xfffffff とかやってらんねーのでしかたなし
    for _ in self.findIndex(prefix): result += 1
    return result
  # abcab*** は [abcab,abcab\0,...abcab\ff\ff\ff\ff] なので lb("abcac") - lb("abcab")
  let (rawIndex,rawIsMatched) = self.lowerBound(prefix)
  if not rawIsMatched: return 0
  var another = prefix
  another[^1] = chr(another[^1].ord + 1)
  let (anotherIndex,_) = self.lowerBound(another)
  return anotherIndex - rawIndex
# index -> 文字列.
proc getString*(S:string,index:int) : string = S[index..^1]
proc getString*(self:SuffixArray,index:int) : string = self.S[index..^1]
proc getAllSuffixArrayString*(self:SuffixArray):seq[string] =
  result = newSeq[string](self.SA.len)
  for i in 0..<self.SA.len:
    result[i] = self.getString(self.SA[i])
# O(Plog|S|+MT) (Tはマッチした文字列の長さ)
iterator findMatchedString*(self:SuffixArray,prefix:string): string =
  for i in self.findIndex(prefix): yield self.getString(i)
proc findAllMatchedString*(self:SuffixArray,prefix:string):seq[string] =
  toSeq(self.findMatchedString(prefix))

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
      check: banana.getCount("an") == 2
      check: banana.getCount("") == 7
      check: banana.getCount("na") == 2
      check: banana.getCount("nan") == 1
      check: banana.getCount("nana") == 1
      check: banana.findAllMatchedString("an") == @["ana", "anana"]
