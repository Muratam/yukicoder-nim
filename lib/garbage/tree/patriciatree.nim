import sequtils

# 2進パトリシア木 + セグツリ. 全ての操作が O(log N).
# キー: 追加,最大,最小,検索,要素数,{以上,以下}列挙,k番目,xor
# 値 :  一点更新, 区間取得
# 最強だが定数倍が重い.std::setの10倍くらい.
# 位置が動的でなくてよいなら,SparseSegmentTreeの方が良い.

# NOTE:
# 現在はキーは非負整数の範囲でのみしか動かない.つらたん. +1e9 / -1e9とかしておいて.
# 現在はキーの削除関数の実装があやしい

type PatriciaSegmentNode[T] = ref object
  to0,to1 : PatriciaSegmentNode[T]
  isLeaf : bool
  count : int32
  keyOrIndex : int # 葉なら value / 枝なら一番下位bitが自身が担当するbit番号.それ以外はprefix
  data : T
type PatriciaSegmentTree[T] = object
  root : PatriciaSegmentNode[T]
  unit : T
  apply*:proc(x,y:T):T
{.overflowChecks:off.}
when NimMajor * 100 + NimMinor >= 18: import bitops
else:
  proc countLeadingZeroBits(x: culonglong): cint {.importc: "__builtin_clzll", cdecl.}
  proc countTrailingZeroBits(x: culonglong): cint {.importc: "__builtin_ctzll", cdecl.}
  proc fastLog2(x:culonglong):cint = 63 - countLeadingZeroBits(x)
proc newPatriciaSegmentNode[T](self:PatriciaSegmentTree[T]):PatriciaSegmentNode[T] =
  new(result)
  result.data = self.unit
proc newPatriciaSegmentLeaf[T](self:PatriciaSegmentTree[T],n:int,val:T) : PatriciaSegmentNode[T] =
  new(result)
  result.isLeaf = true
  result.keyOrIndex = n
  result.count = 1
  result.data = val
proc newPatriciaSegmentTree*[T](apply:proc(x,y:T):T,unit:T,bitSize:int = 62):PatriciaSegmentTree[T] =
  result.unit = unit
  result.apply = apply
  result.root = result.newPatriciaSegmentNode()
  result.root.count = 0
  result.root.isLeaf = false
  result.root.keyOrIndex = 1 shl bitSize
proc bitSize[T](self:PatriciaSegmentNode[T]):int =
  self.keyOrIndex.culonglong.countTrailingZeroBits.int
proc isTo1[T](self:PatriciaSegmentNode[T],n:int):bool{.inline.} =
  (self.keyOrIndex and n) == self.keyOrIndex # 上位bitは同じはずなので
import strutils
proc binary*(x:int,fill:int=0):string = # 二進表示
  if x == 0 : return "0".repeat(fill)
  if x < 0  : return binary(int.high+x+1,fill)
  result = ""
  var x = x
  while x > 0:
    result .add chr('0'.ord + x mod 2)
    x = x div 2
  for i in 0..<result.len div 2: swap(result[i],result[result.len-1-i])
  if result.len >= fill: return result[^fill..^1]
  return "0".repeat(0.max(fill - result.len)) & result
proc dump*[T](self:PatriciaSegmentNode[T],indent:int = 0) : string =
  if self == nil : return ""
  result = ""
  result .add self.keyOrIndex.binary(60)
  result .add "\t"
  result .add $self.count
  result .add " "
  result .add $self.data
  result .add " "
  for i in 0..<indent: result .add "  "
  if self.isLeaf: result.add "_"
  else: result.add "|"
  result = result & "\n"
  if self.isLeaf: return
  if self.to0 != nil: result.add self.to0.dump(indent + 1)
  if self.to1 != nil: result.add self.to1.dump(indent + 1)
proc dump*[T](self:PatriciaSegmentTree[T]) : string = self.root.dump()
# キー が 存在するか
proc contains*[T](self:PatriciaSegmentTree[T],n:int) : bool =
  var now = self.root
  while not now.isLeaf:
    if now.isTo1(n):
      if now.to1 == nil : return false
      now = now.to1
    else:
      if now.to0 == nil : return false
      now = now.to0
  return now.keyOrIndex == n
proc `$`*[T](self:PatriciaSegmentNode[T]):string =
  if self == nil : return "nil"
  if not self.isLeaf: return " - "
  return "("&($self.keyOrIndex)&","&($self.data)&")"
proc key*[T](self:PatriciaSegmentNode[T]):int = self.keyOrIndex
# 全体の要素数
proc len*[T](self:PatriciaSegmentTree[T]) : int = self.root.count
proc createInternalNode[T](self:var PatriciaSegmentTree[T],now:PatriciaSegmentNode,preTree:PatriciaSegmentNode,n:int,val:T) : PatriciaSegmentNode[T] =
  let cross = preTree.keyOrIndex xor n
  var bit = 0
  # 頑張れば bit 演算にできそう.
  for bitI in (now.bitSize() - 1).countdown(0):
    if (cross and (1 shl bitI)) == 0 : continue
    bit = bitI
  var newLeaf = self.newPatriciaSegmentLeaf(n,val)
  var created = self.newPatriciaSegmentNode()
  created.isLeaf = false
  let n1 = preTree.keyOrIndex
  let n2 = newLeaf.keyOrIndex
  # fastLog2 は (n and -n)で累乗にできるね
  let n3 = 1 shl (n1 xor n2).culonglong.fastLog2()
  created.keyOrIndex = (n1 or n2) and (not (n3 - 1))
  created.count = newLeaf.count + preTree.count
  if created.isTo1(newLeaf.keyOrIndex):
    created.to1 = newLeaf
    created.to0 = preTree
  else:
    created.to1 = preTree
    created.to0 = newLeaf
  return created
# 追加・取得
proc `[]=`*[T](self:var PatriciaSegmentTree[T],n:int,val:T) =
  var existsKey = n in self
  var now = self.root
  var target : PatriciaSegmentNode[T] = nil
  var path = @[now]
  while true:
    if not existsKey : now.count += 1
    let nowIsTo1 = now.isTo1(n)
    if nowIsTo1: target = now.to1
    else: target = now.to0
    proc backwardFromLeaf(self:var PatriciaSegmentTree[T],updateNow:bool = true) =
      if updateNow:
        if nowIsTo1: now.to1 = target
        else: now.to0 = target
      path.add target
      for i in (path.len-1).countdown(0):
        if path[i].to0 == nil:
          if path[i].to1 == nil: continue
          path[i].data = path[i].to1.data
        elif path[i].to1 == nil:
          path[i].data = path[i].to0.data
        else:
          path[i].data = self.apply(path[i].to0.data,path[i].to1.data)
      # self.backward(path)
    # ノードを見ていく
    if target == nil:
      # この先が空なので直接葉を作る
      target = self.newPatriciaSegmentLeaf(n,val)
      self.backwardFromLeaf()
      return
    elif target.isLeaf:
      let existsLeaf = target.keyOrIndex == n
      if existsLeaf: # 葉があった
        if not existsKey : target.count += 1
        target.data = val
      else:
        target = self.createInternalNode(now,target,n,val)
      self.backwardFromLeaf(not existsLeaf)
      return
    else:
      let x = target.keyOrIndex
      let mask = not(x xor (x - 1))
      # prefix が違ったので新しくそこに作る
      if (x and mask) != (n and mask) :
        target = self.createInternalNode(now,target,n,val)
        self.backwardFromLeaf()
        return
      path.add target
      now = target
proc `[]`*[T](self:PatriciaSegmentTree[T],n:int) : T =
  var now = self.root
  while not now.isLeaf:
    if now.isTo1(n):
      if now.to1 == nil :
        return self.unit
      now = now.to1
    else:
      if now.to0 == nil :
        return self.unit
      now = now.to0
  if now.keyOrIndex == n:
    return now.data
  return self.unit
proc at[T](node:PatriciaSegmentNode[T]):Slice[int] =
  let v = node.keyOrIndex
  if node.isLeaf: return v..v
  # if v == 0 : return -9223372036854775807.int..9223372036854775807.int # NOTE: -1 ~ ってちょっとおかしいよね
  #  1010100 は 1010___ なので [1010000,1010111) を表す
  # -0000100 ~ +0000100 の範囲を表す
  let minKey = v and (-v)
  return (v-minKey)..<(v+minKey)
proc queryImpl[T](self:PatriciaSegmentTree[T],target:Slice[int],now:PatriciaSegmentNode) : T =
  let nowat = now.at
  if nowat.b < target.a or target.b < nowat.a : # 完全に範囲外
    return self.unit
  if target.a <= nowat.a and nowat.b <= target.b: # 完全に範囲内
    return now.data
  if now.to0 == nil :
    if now.to1 == nil : return now.data
    return self.queryImpl(target,now.to1)
  if now.to1 == nil :
    return self.queryImpl(target,now.to0)
  let vl = self.queryImpl(target,now.to0)
  let vr = self.queryImpl(target,now.to1)
  return self.apply(vl,vr)
proc countImpl[T](self:PatriciaSegmentTree[T],target:Slice[int],now:PatriciaSegmentNode) : int =
  let nowat = now.at
  if nowat.b < target.a or target.b < nowat.a : # 完全に範囲外
    return 0
  if target.a <= nowat.a and nowat.b <= target.b: # 完全に範囲内
    return now.count
  if now.to0 == nil :
    if now.to1 == nil : return now.count
    return self.countImpl(target,now.to1)
  if now.to1 == nil :
    return self.countImpl(target,now.to0)
  let vl = self.countImpl(target,now.to0)
  let vr = self.countImpl(target,now.to1)
  return vl + vr
# 区間内のモノイド値取得
proc `[]`*[T](self:PatriciaSegmentTree[T],slice:Slice[int]): T =
  self.queryImpl(slice.a..slice.b,self.root)
# 区間内の要素数
proc count*[T](self:PatriciaSegmentTree[T],slice:Slice[int]): int =
  self.countImpl(slice.a..slice.b,self.root)
# 区間内の要素を列挙
iterator at*[T](self:PatriciaSegmentTree[T],target:Slice[int],isDesc:bool=false):tuple[k:int,v:T] =
  var stack = @[self.root]
  while stack.len > 0:
    let now = stack.pop()
    if now.isLeaf:
      assert target.a <= now.keyOrIndex and now.keyOrIndex <= target.b
      yield (now.keyOrIndex,now.data)
      continue
    proc addTo(next:PatriciaSegmentNode[T]) =
      if next == nil: return
      let nextAt = next.at()
      if not(nextAt.b < target.a or target.b < nextAt.a): # 完全に範囲外、ということでなければ
        stack.add next
    if not isDesc:
      addTo(now.to1)
      addTo(now.to0)
    else:
      addTo(now.to0)
      addTo(now.to1)
proc minKey*[T](self:PatriciaSegmentTree[T]): PatriciaSegmentNode[T] =
  if self.root.count <= 0 : return nil
  # to0 の方から渡っていけばよい
  var now = self.root
  while not now.isLeaf:
    if now.to0 != nil: now = now.to0
    else: now = now.to1
  return now
proc maxKey*[T](self:PatriciaSegmentTree[T]): PatriciaSegmentNode[T] =
  if self.root.count <= 0 : return nil
  # to1 の方から渡っていけばよい
  var now = self.root
  while not now.isLeaf:
    if now.to1 != nil: now = now.to1
    else: now = now.to0
  return now
# 0-indexed.
proc ithKey*[T](self:PatriciaSegmentTree[T],i:int): PatriciaSegmentNode[T] =
  if self.root.count <= 0 : return nil
  if i < 0 or i >= self.root.count : return nil
  var now = self.root
  var offset = 0
  while not now.isLeaf:
    # 3th [cnt 10[4][6]] <  >> offset = 0
    # 4th [cnt 10[4][6]] >  >> offset = 4
    if now.to0 == nil: now = now.to1
    elif now.to1 == nil: now = now.to0
    else:
      if i - offset < now.to0.count :
        now = now.to0
      else:
        offset += now.to0.count
        now = now.to1
  return now
# 削除. 削除した場合無駄な枝(1方向しかない)が残る雑実装.
# 動作はするがその後の操作に無限に邪魔になって遅くなるがもともと遅いしいいかな...
proc erase*[T](self:PatriciaSegmentTree[T],n:int) : bool {.discardable.}=
  var path = @[self.root]
  while not path[^1].isLeaf:
    if path[^1].isTo1(n):
      if path[^1].to1 == nil : return false
      path.add path[^1].to1
    else:
      if path[^1].to0 == nil : return false
      path.add path[^1].to0
  if path[^1].keyOrIndex != n : return false
  assert path.len >= 2
  # 葉の一つ上をぶっち切る
  var cutFlag = true
  for i in (path.len-2).countdown(0):
    if cutFlag:
      let isTo1i = path[i].isTo1(n)
      if isTo1i:
        path[i].to1 = nil
        cutFlag = path[i].to0 == nil
      else:
        path[i].to0 = nil
        cutFlag = path[i].to1 == nil
      # 両方消えた
      if cutFlag: continue
      # 片方だけしか消えなかった
      path[i].count -= 1
      if isTo1i: path[i].data = path[i].to0.data
      else: path[i].data = path[i].to1.data
      continue
    path[i].count -= 1
    if path[i].to0 == nil:
      path[i].data = path[i].to1.data
    elif path[i].to1 == nil:
      path[i].data = path[i].to0.data
    else:
      path[i].data = self.apply(path[i].to0.data,path[i].to1.data)

when isMainModule:
  import unittest
  test "patricia segment tree":
    var T = newPatriciaSegmentTree(proc(x,y:string):string = x&y,"")
    T[6] = "A"
    check:T.minKey().key == 6
    T[3] = "B"
    check:T.minKey().key == 3
    check:T.maxKey().key == 6
    T[7] = "D"
    T[7] = "E"
    check:T.maxKey().key == 7
    T[15] = "F"
    T[0] = "G"
    check:T.maxKey().key == 15
    check:T.minKey().key == 0
    check: T[0..15] == "GBAEF"
    check: T.count(0..15) == 5
    check: T[4..8] == "AE"
    check: T.count(4..8) == 2
    check: T[2..3] == "B"
    check: T[3..3] == "B"
    T[3] = "H"
    check: T[3..4] == "H"
    check: T[4..4] == ""
    check: T[3..7] == "HAE"
    check: T.count(3..7) == 3
    check: T[0..15] == "GHAEF"
    # echo ($toSeq(T.at(1..15)))
    # echo toSeq(T.at(1..15,true))
    # echo toSeq(-1..5).mapIt(T.ithKey(it))
    # check: T.dump()
  test "patricia segment tree cut":
    var T = newPatriciaSegmentTree(proc(x,y:string):string = x&y,"")
    T[6] = "A"
    check:T.minKey().key == 6
    T[3] = "B"
    check:T.minKey().key == 3
    check:T.maxKey().key == 6
    T[7] = "D"
    T[7] = "E"
    check:T.maxKey().key == 7
    T[15] = "F"
    T[0] = "G"
    # echo T.maxKey()
    # T.erase(15)
    # echo T.maxKey()
    # echo T.minKey()
    # T.erase(0)
    # echo T.minKey()
    # T.erase(15)
    # echo T.minKey()
    # T.erase(3)
    # echo T.minKey()
    # T[3] = "X"
    # T[12] = "Y"
    # echo T.maxKey()
