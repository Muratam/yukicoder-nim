import sequtils,algorithm,math,tables,sets,strutils,times
# SA
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
# Pが長い場合 RMQで O(P+(log|S|)^2) にもできる
proc lowerBound*(self:SuffixArray,prefix:string): tuple[index:int,isMatched:bool] =
  # i := {S} >= prefix の最小の位置を返却
  var now = -1..self.S.len + 1
  proc compare(start:int):int =
    self.S[start..<self.S.len.min(start+prefix.len)].cmp(prefix)
    # 今後セグツリで  にしたくなった時用.
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

template time*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord
import times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")

let S = stdin.readLine()
let m = scan()
var P = newSeq[string](m)
for i in 0..<m: P[i] = stdin.readLine()
let W = newSeqWith(m,scan().int16)
let SA = S.newSuffixArray()
var match : array[200010,array[210,int16]]

# 文字の位置 -> 文字のサイズ の中で最大の重みを保存
stopwatch:
  # lowerbound は 430ms のうち 60msのコスト
  for i,p in P:
    for found in SA.findIndex(p):
      match[found][p.len] .max= W[i]
stopwatch:
  var dp = newSeq[int](S.len+1)
  for i in 0..<S.len:
    for l,w in match[i]: # 長さ毎に最大の重み
      if i+l >= dp.len: continue
      dp[i+l] .max= dp[i] + w
    dp[i+1] .max= dp[i]
  # echo dp
  echo dp[^1]
