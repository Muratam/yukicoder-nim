# https://www.slideshare.net/iwiwi/2-12188757
# std::set の代替. Treap.nim とは実装が違ってしまうかも...
# 0. min,max,find,add,erase,iter
# 1. key には int以外のカスタムの比較関数も取れる
# verified : https://atcoder.jp/contests/abc140/tasks/abc140_f
# std::map の 3 ~ 5倍遅い...

import sequtils
# 余分な葉が無いので半群(モノイドに比べて単位元が不要)でよい
import times
type Treap*[T] = ref object
  key*: T
  priority*: int32
  left*,right*: Treap[T]
  sameCount*:int32 # 破滅
import algorithm,math,strutils
var xorShiftVar* = 88172645463325252.uint64
xorShiftVar = cast[uint64](cpuTime()) # 初期値を固定しない場合
proc xorShift() : uint64 =
  xorShiftVar = xorShiftVar xor (xorShiftVar shl 13)
  xorShiftVar = xorShiftVar xor (xorShiftVar shr 7)
  xorShiftVar = xorShiftVar xor (xorShiftVar shl 17)
  return xorShiftVar
proc randomBit(maxBit:int):int =
  cast[int](xorShift() and cast[uint64]((1 shl maxBit) - 1))
proc dump*[T](self:Treap[T],indent:int,mark:string="^") : string =
  if self == nil : return ""
  result = "|".repeat(indent) & " " & mark & " " & ($self.key) & " (x" & $self.sameCount & ")\n"
  result .add self.right.dump(indent+1,"<")
  result .add self.left.dump(indent+1,">")
proc newTreap*[T](key:T):Treap[T] =
  result = Treap[T](
    key:key,
    priority:randomBit(30).int32,
    sameCount:1,
  )
# merge / split (left: [-∞..key) / right: (key,∞))
# 対称にしておくことで,木の平衡を保つ,というか勝手にそうなってる.
proc merge*[T](left,right:Treap[T]) : Treap[T] =
  # 必ず ∀[left] < ∀[right] の時に呼ばれるという仮定を置いている
  if left == nil: return right
  if right == nil : return left
  # 優先度が高い方を根にする
  if left.priority > right.priority:
    left.right = left.right.merge(right)
    return left
  else:
    right.left = left.merge(right.left)
    return right
proc split*[T](self:Treap[T],key:T,wantAdd:bool = false): tuple[l,r:Treap[T]] =
  # 再帰的に切るだけ. (子は必ず優先度が低いので)
  if self == nil: return (nil,nil)
  if key < self.key:
    let s = self.left.split(key)
    self.left = s.r
    return (s.l,self)
  else:
    let s = self.right.split(key)
    self.right = s.l
    return (self,s.r)
# 検索・挿入・削除
proc find*[T](self:Treap[T],key:T) : Treap[T]=
  if self == nil : return nil
  if self.key == key: return self
  if key < self.key:
    if self.left == nil : return nil
    return self.left.find(key)
  else:
    if self.right == nil: return nil
    return self.right.find(key)
proc singleAdd*[T](self:var Treap[T],item: Treap[T]): bool {.discardable.}=
  if self == nil:
    self = item
  elif item.priority > self.priority:
    let found = self.find(item.key)
    if found != nil: return false
    let s = self.split(item.key)
    self = item
    self.left = s.l
    self.right = s.r
  elif item.key < self.key:
    self.left.singleAdd(item)
  else:
    self.right.singleAdd(item)
  return true
proc multiAdd*[T](self:var Treap[T],item: Treap[T]) =
  if self == nil:
    self = item
  elif item.key == self.key:
    self.sameCount += 1
  elif item.priority > self.priority:
    let found = self.find(item.key)
    if found != nil:
      found.sameCount += 1
      return
    let s = self.split(item.key)
    self = item
    self.left = s.l
    self.right = s.r
  elif item.key < self.key:
    self.left.multiAdd(item)
  else:
    self.right.multiAdd(item)
proc erase*[T](self:var Treap[T],key:T) :bool {.discardable.} =
  # 自分にさようなら
  if self.key == key:
    if self.sameCount > 1:
      self.sameCount -= 1
    else:
      self = self.left.merge(self.right)
    return true
  elif key < self.key:
    if self.left == nil : return false
    result = self.left.erase(key)
  else:
    if self.right == nil : return false
    result = self.right.erase(key)
# 検索最小値,最大値
proc min*[T](self:Treap[T]) : Treap[T] =
  if self == nil : return nil
  if self.left == nil: return self
  return self.left.min()
proc max*[T](self:Treap[T]) : Treap[T] =
  if self == nil : return nil
  if self.right == nil: return self
  return self.right.max()
# 自身以下の木が表す範囲
proc at*[T](self:Treap[T]): Slice[T] =
  if self == nil : return nil
  if self.left == nil : result.a = self.key
  else: result.a = self.min()
  if self.right == nil: result.b = self.key
  else: result.b = self.max()
# 自身を含むノードを全て列挙(昇順)
iterator items*[T](self:Treap[T]) : Treap[T] =
  var treaps = @[self]
  var chunks = newSeq[Treap[T]]() # 親
  while treaps.len > 0:
    let now = treaps.pop()
    if now == nil : continue
    if now.right != nil:
      treaps.add now.right
    if now.left != nil:
      treaps.add now.left
    while chunks.len > 0 and now.key > chunks[^1].key:
      yield chunks.pop()
    chunks.add now
  while chunks.len > 0:
    yield chunks.pop()
# 自身を含むノードを全て列挙(降順)
iterator itemsDesc*[T](self:Treap[T]) : Treap[T] =
  var treaps = @[self]
  var chunks = newSeq[Treap[T]]() # 親
  while treaps.len > 0:
    let now = treaps.pop()
    if now == nil : continue
    if now.left != nil:
      treaps.add now.left
    if now.right != nil:
      treaps.add now.right
    while chunks.len > 0 and now.key < chunks[^1].key:
      yield chunks.pop()
    chunks.add now
  while chunks.len > 0:
    yield chunks.pop()
# キー以上のものを全て列挙(昇順)
iterator over*[T](self:Treap[T],key:T,including:bool) : Treap[T] =
  var treaps = @[self]
  var chunks = newSeq[Treap[T]]() # 親
  while treaps.len > 0:
    let now = treaps.pop()
    if now == nil : continue
    if now.right != nil:
      treaps.add now.right
    if (including and now.key >= key) or (not including and now.key > key):
      if now.left != nil:
        treaps.add now.left
      while chunks.len > 0 and now.key > chunks[^1].key:
        yield chunks.pop()
      chunks.add now
  while chunks.len > 0:
    yield chunks.pop()
iterator `>=`*[T](self:Treap[T],key:T) : Treap[T] =
  for v in self.over(key,true): yield v
iterator `>`*[T](self:Treap[T],key:T) : Treap[T] =
  for v in self.over(key,false): yield v
# キー以下のものを全て列挙(降順)
iterator under*[T](self:Treap[T],key:T,including:bool) : Treap[T] =
  var treaps = @[self]
  var chunks = newSeq[Treap[T]]() # 親
  while treaps.len > 0:
    let now = treaps.pop()
    if now == nil : continue
    if now.left != nil:
      treaps.add now.left
    if (including and now.key <= key) or (not including and now.key < key):
      if now.right != nil:
        treaps.add now.right
      while chunks.len > 0 and now.key < chunks[^1].key:
        yield chunks.pop()
      chunks.add now
  while chunks.len > 0:
    yield chunks.pop()
iterator `<=`*[T](self:Treap[T],key:T) : Treap[T] =
  for v in self.under(key,true): yield v
iterator `<`*[T](self:Treap[T],key:T) : Treap[T] =
  for v in self.under(key,false): yield v
# 一つだけ欲しい場合
proc findGreater*[T](self:Treap[T],key:T,including:bool) : Treap[T] =
  if self == nil: return nil
  if including and self.key == key: return self
  let r = self.left.findGreater(key,including)
  if r != nil: return r
  if self.key > key: return self
  return self.right.findGreater(key,including)
proc findLess*[T](self:Treap[T],key:T,including:bool) : Treap[T] =
  if self == nil: return nil
  if including and self.key == key: return self
  let r = self.right.findLess(key,including)
  if r != nil: return r
  if self.key < key: return self
  return self.left.findLess(key,including)

# 木自身(*.root以降)はイテレータとなっているので、そちらを操作するとより多くの情報が得られる
# こちらは情報をfilterすることで使いやすくしたもの
type TreapRoot*[T] = ref object
  # Treapの根を指すラッパーを作成することで、いろいろな操作がしやすい.
  # 特に,自身は必ず nil ではないので操作がやりやすい.
  root*:Treap[T]
  allowMulti*:bool
  count*:int
# コンストラクタ
proc newTreapRoot*[T](allowMulti:bool = true):TreapRoot[T] =
  result = TreapRoot[T](allowMulti:allowMulti)
# どこかで見つけた部分木(*.rootを中心にイテレータを回して取るなど)を根にする.
proc toRoot*[T](self:TreapRoot[T],treap:Treap[T]):TreapRoot[T] =
  result = TreapRoot[T](
    allowMulti:self.allowMulti,
    root:treap
  )
# 挿入,削除,キー検索,要素数
proc erase*[T](self:var TreapRoot[T],key:T) : bool {.discardable.}=
  if self.root == nil : return
  result = self.root.erase(key)
  if result : self.count -= 1
proc len*[T](self:TreapRoot[T]) : int =
  if self.root == nil : return 0
  return self.count
proc contains*[T](self:TreapRoot[T],key:T):bool=
  if self.root == nil : return false
  return self.root.find(key) != nil
proc add*[T](self:var TreapRoot[T],key:T) =
  # 無ければ追加.とすることで擬似的に multiadd / add を切り替えられる(multiじゃないときはコストだが)
  if self.allowMulti:
    self.root.multiAdd(newTreap(key))
    self.count += 1
  elif self.root.singleAdd(newTreap(key)):
    self.count += 1
# 検索. 最小値,最大値
proc min*[T](self:TreapRoot[T]): T =
  return self.root.min().key
proc max*[T](self:TreapRoot[T]): T =
  return self.root.max().key
proc at*[T](self:TreapRoot[T]): Slice[T] = self.root.at()
# 全列挙(昇順 / 降順)
iterator items*[T](self:TreapRoot[T]) : T =
  if self.root != nil:
    for v in self.root:
      for _ in 0..<v.sameCount: yield v.key
iterator itemsDesc*[T](self:TreapRoot[T]) : T =
  if self.root != nil :
    for v in self.root.itemsDesc:
      for _ in 0..<v.sameCount: yield v.key
# キー以上のものを全て列挙(昇順)
iterator `>=`*[T](self:TreapRoot[T],key:T) : T =
  if self.root != nil :
    for v in self.root.over(key,true):
      for _ in 0..<v.sameCount: yield v.key
iterator `>`*[T](self:TreapRoot[T],key:T) : T =
  if self.root != nil :
    for v in self.root.over(key,false):
      for _ in 0..<v.sameCount: yield v.key
# キー以下のものを全て列挙(降順)
iterator `<=`*[T](self:TreapRoot[T],key:T) : T =
  if self.root != nil :
    for v in self.root.under(key,true):
      for _ in 0..<v.sameCount: yield v.key
iterator `<`*[T](self:TreapRoot[T],key:T) : T =
  if self.root != nil :
    for v in self.root.under(key,false):
      for _ in 0..<v.sameCount: yield v.key
proc dump*[T](self:TreapRoot[T]) : string = self.root.dump(0)
# 完全な平衡二分探索木を構築する.定数倍速い.
import math
proc resetWith*[T](self:var TreapRoot[T],arr:seq[T]) =
  self.root = nil
  self.count = 0
  if arr.len <= 0 : return
  var S = newSeq[T]()
  var counts = newSeq[int32]()
  for a in arr.sorted(cmp[T]):
    if S.len > 0 and S[^1] == a :
      if self.allowMulti:
        counts[^1] += 1
      continue
    S.add a
    counts.add 1
  var R = newSeq[int32]((10+S.len).nextPowerOfTwo())
  for i in 0..<R.len:
    R[i] = randomBit(30).int32
  R.sort(cmp)
  var cnt = 0
  proc impl(now:var Treap[T],ri,si,offset:int) =
    if ri < R.len and si < S.len and si >= 0:
      now = Treap[T](key:S[si],priority:R[ri],sameCount:counts[si])
      cnt += 1
    if offset != 0 :
      if now == nil:
        now.impl(ri*2+1,si-offset,offset shr 1)
      else:
        now.left.impl(ri*2+1,si-offset,offset shr 1)
        now.right.impl(ri*2+2,si+offset,offset shr 1)
  let offset = (S.len + 2).nextPowerOfTwo() shr 2
  let mid = offset * 2 - 1
  self.root.impl(0,mid,offset)
  self.count = S.len

import times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
if false:
  let n = 1e6.int
  stopwatch:
    var x = 0
    var A = newTreapRoot[int]()
    for i in 0..<n: A.add randomBit(32)
    # for i in 0..<n:
    #   if randomBit(32) in A : x += 1
    echo x,":",A.len
when isMainModule:
  import unittest
  import sequtils
  test "Treap":
    block:
      xorShiftVar = 88172645463325252.uint64
      for k in 0..<1:
        var A = newTreapRoot[int]()
        for i in 0..<20:
          A.add randomBit(5)
        echo A.min()
        echo A.max()
        echo A.dump()
        echo toSeq(A.items)
        echo toSeq(A.itemsDesc)
        let n = 18
        echo toSeq(A >= n)
        echo toSeq(A > n)
        let x = toSeq(A < n)
        echo x
        echo toSeq(A <= n)
        for xi in 1..<x.len:
          if x[xi-1] < x[xi] :
            echo x
            echo A.dump()
            quit 0
        for i in 0..<10:
          A.erase randomBit(5)
