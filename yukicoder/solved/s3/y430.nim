import sequtils,algorithm
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

type SuffixArray = ref object
  S : string
  SA : seq[int]
  LCP : seq[int]
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
proc newSuffixArray(S:string):SuffixArray =
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
iterator find(self:SuffixArray,target:string): int =
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
proc getCount(self:SuffixArray,target:string): int =
  for _ in self.find(target): result += 1

let S = stdin.readLine()
let SA = S.newSuffixArray()
var ans = 0
scan().times:
  let T = stdin.readLine()
  ans += SA.getCount(T)
echo ans
