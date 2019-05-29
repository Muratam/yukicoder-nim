import sequtils

# 二部グラフの最大マッチング
template useBiparticeMatching() =
  # 二部グラフの最大マッチング O(E)
  type BipartiteMatch = seq[seq[int]]
  proc initBipartiteMatch(maxSize:int): BipartiteMatch = newSeqWith(maxSize,newSeq[int]())
  proc add(B:var BipartiteMatch,src,dst:int) = (B[dst] &= src;B[src] &= dst)
  proc bipartiteMatching(B:BipartiteMatch) : tuple[match:seq[int],size:int] =
    var match = newSeqWith(B.len,-1)
    var used : seq[bool]
    proc dfs(src:int) : bool =
      # 交互にペアを結んでいく
      used[src] = true
      for dst in B[src]:
        if match[dst] >= 0 :
          if used[match[dst]] : continue
          if not dfs(match[dst]) : continue
        match[src] = dst
        match[dst] = src
        return true
      return false
    var size = 0
    for src in 0..<B.len:
      if match[src] >= 0 : continue
      used = newSeq[bool](B.len)
      if dfs(src) : size += 1
    return (match,size)
useBiparticeMatching()

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
var BM = initBipartiteMatch(2*n)
for i in 0..<n:
  let bad = scan()
  for j in 0..<n:
    if j == bad : continue
    BM.add(i,n+j)
let (match,size) = BM.bipartiteMatching()
if size != n : quit "-1",0
for i in 0..<n:  echo match[i]-n