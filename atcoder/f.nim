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

type Edge = tuple[dst:int,color:int,length:int]
let n = scan()
let q = scan()
var E = newSeqWith(n,newSeq[Edge]())
var LC = newSeqWith(n,newSeq[int]())
var D = newSeqWith(n,0)

proc fastlog2_nim(x: uint64): int {.inline, nosideeffect.} =
  ## Quickly find the log base 2 of a 64-bit integer.
  # https://graphics.stanford.edu/%7Eseander/bithacks.html#IntegerLogDeBruijn
  # https://stackoverflow.com/questions/11376288/fast-computing-of-log2-for-64-bit-integers
  const lookup: array[64, uint8] = [0'u8, 58, 1, 59, 47, 53, 2, 60, 39, 48, 27, 54,
    33, 42, 3, 61, 51, 37, 40, 49, 18, 28, 20, 55, 30, 34, 11, 43, 14, 22, 4, 62,
    57, 46, 52, 38, 26, 32, 41, 50, 36, 17, 19, 29, 10, 13, 21, 56, 45, 25, 31,
    35, 16, 9, 12, 44, 24, 15, 8, 23, 7, 6, 5, 63]
  var v = x.uint64
  v = v or v shr 1 # first round down to one less than a power of 2
  v = v or v shr 2
  v = v or v shr 4
  v = v or v shr 8
  v = v or v shr 16
  v = v or v shr 32
  result = lookup[(v * 0x03F6EAF2CD271461'u64) shr 58].int

proc asTree(E:seq[seq[Edge]]):seq[seq[Edge]] =
  var answer = newSeqWith(E.len,newSeq[Edge]())
  proc impl(pre,now,sum:int) =
    D[now] = sum
    for dst in E[now]:
      if dst.dst == pre : continue
      answer[now].add(dst)
      impl(now,dst.dst,sum+dst.length)
  impl(-1,0,0)
  return answer

proc asTreeInt(E:seq[seq[int]]):seq[seq[int]] =
  var answer = newSeqWith(E.len,newSeq[int]())
  proc impl(pre,now:int) =
    for dst in E[now]:
      if dst == pre : continue
      answer[now].add(dst)
      impl(now,dst)
  impl(-1,0)
  return answer


# 最小共通祖先 構築:O(n),探索:O(log(n)) (深さに依存しない)
type LowestCommonAncestor = ref object
  depth : seq[int]
  parent : seq[seq[int]] # 2^k 回親をたどった時のノード
  n:int
  nlog2 : int
proc newLowestCommonAnsestor(E:seq[seq[int]],root:int = 0) : LowestCommonAncestor =
  new(result)
  # E:隣接リスト,root:根の番号,(0~E.len-1と仮定)
  # 予め木を整形(= E[i]で親と子の区別を行う)する必要はない
  let n = E.len
  let nlog2 = E.len.uint64.fastlog2_nim() + 1
  var depth = newSeq[int](n)
  var parent = newSeqWith(nlog2,newSeq[int](E.len))
  proc fill0thParent(src,pre,currentDepth:int) =
    parent[0][src] = pre
    depth[src] = currentDepth
    for dst in E[src]:
      if dst != pre : fill0thParent(dst,src,currentDepth+1)
  fill0thParent(root,-1,0)
  for k in 0..<nlog2-1:
    for v in 0..<n:
      if parent[k][v] < 0 : parent[k+1][v] = -1
      else: parent[k+1][v] = parent[k][parent[k][v]]
  result.depth = depth
  result.parent = parent
  result.n = n
  result.nlog2 = nlog2
proc find(self:LowestCommonAncestor,u,v:int):int =
  var (u,v) = (u,v)
  if self.depth[u] > self.depth[v] : swap(u,v)
  for k in 0..<self.nlog2:
    if (((self.depth[v] - self.depth[u]) shr k) and 1) != 0 :
      v = self.parent[k][v]
  if u == v : return u
  for k in (self.nlog2-1).countdown(0):
    if self.parent[k][u] == self.parent[k][v] : continue
    u = self.parent[k][u]
    v = self.parent[k][v]
  return self.parent[0][u]


(n-1).times:
  let a = scan()-1
  let b = scan()-1
  let c = scan()
  let d = scan()
  E[a].add((b,c,d))
  E[b].add((a,c,d))
  LC[a].add(b)
  LC[b].add(a)
q.times:
  let x = scan()
  let y = scan()
  let u = scan()
  let v = scan()
  echo x,y,u,v
E = E.asTree()
LC = LC.asTreeInt()
var LCA = newLowestCommonAnsestor(LC)


# 色テーブルがよういできねえええええええええええええええ
echo E
echo D
echo LC
