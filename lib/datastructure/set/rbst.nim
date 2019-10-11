# rbstの強化版
# rbst + split , merge , kth
# verified : https://atcoder.jp/contests/abc140/tasks/abc140_f

import sequtils
import times
type Rbst*[T] = ref object
  key*: T
  count*: int32 # 自分を含む要素の和
  left*,right*: Rbst[T]
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
proc dump*[T](self:Rbst[T],indent:int,mark:string="^") : string =
  if self == nil : return ""
  result = "|".repeat(indent) & " " & mark & " " & ($self.key) & " (x" & $self.sameCount & ")\n"
  result .add self.right.dump(indent+1,"<")
  result .add self.left.dump(indent+1,">")
proc newRbst*[T](key:T):Rbst[T] =
  result = Rbst[T](
    key:key,
    sameCount:1,
  )
proc len*[T](self:Rbst[T]):int = self.count.int
# merge / split (left: [-∞..key) / right: (key,∞))
# 対称にしておくことで,木の平衡を保つ,というか勝手にそうなってる.
proc update*[T](self:Rbst[T]) : Rbst[T] =
  self.count = (self.left.len + self.right.len + 1).int32
  return self
proc merge*[T](left,right:Rbst[T]) : Rbst[T] =
  # 必ず ∀[left] < ∀[right] の時に呼ばれるという仮定を置いている
  if left == nil: return right
  if right == nil : return left
  # 優先度が高い方を根にする
  if randomBit(60) mod (left.count + right.count) < left.count:
    left.right = left.right.merge(right)
    return left.update()
  else:
    right.left = left.merge(right.left)
    return right.update()
proc split*[T](self:Rbst[T],key:T): tuple[l,r:Rbst[T]] =
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
proc find*[T](self:Rbst[T],key:T) : Rbst[T]=
  if self == nil : return nil
  if self.key == key: return self
  if key < self.key:
    if self.left == nil : return nil
    return self.left.find(key)
  else:
    if self.right == nil: return nil
    return self.right.find(key)
# WARN: add の仕方を変えると速くなる？
proc singleAdd*[T](self:var Rbst[T],item: Rbst[T]): bool {.discardable.}=
  if self == nil:
    self = item
  else:
    let s = self.split(item.key)
  return true
proc multiAdd*[T](self:var Rbst[T],item: Rbst[T]) =
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
proc erase*[T](self:var Rbst[T],key:T) :bool {.discardable.} =
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
proc min*[T](self:Rbst[T]) : Rbst[T] =
  if self == nil : return nil
  if self.left == nil: return self
  return self.left.min()
proc max*[T](self:Rbst[T]) : Rbst[T] =
  if self == nil : return nil
  if self.right == nil: return self
  return self.right.max()
# 自身以下の木が表す範囲
proc at*[T](self:Rbst[T]): Slice[T] =
  if self == nil : return nil
  if self.left == nil : result.a = self.key
  else: result.a = self.min()
  if self.right == nil: result.b = self.key
  else: result.b = self.max()
# 自身を含むノードを全て列挙(昇順)
iterator items*[T](self:Rbst[T]) : Rbst[T] =
  var rbsts = @[self]
  var chunks = newSeq[Rbst[T]]() # 親
  while rbsts.len > 0:
    let now = rbsts.pop()
    if now == nil : continue
    if now.right != nil:
      rbsts.add now.right
    if now.left != nil:
      rbsts.add now.left
    while chunks.len > 0 and now.key > chunks[^1].key:
      yield chunks.pop()
    chunks.add now
  while chunks.len > 0:
    yield chunks.pop()
# 自身を含むノードを全て列挙(降順)
iterator itemsDesc*[T](self:Rbst[T]) : Rbst[T] =
  var rbsts = @[self]
  var chunks = newSeq[Rbst[T]]() # 親
  while rbsts.len > 0:
    let now = rbsts.pop()
    if now == nil : continue
    if now.left != nil:
      rbsts.add now.left
    if now.right != nil:
      rbsts.add now.right
    while chunks.len > 0 and now.key < chunks[^1].key:
      yield chunks.pop()
    chunks.add now
  while chunks.len > 0:
    yield chunks.pop()
# キー以上のものを全て列挙(昇順)
iterator greater*[T](self:Rbst[T],key:T,including:bool) : Rbst[T] =
  var rbsts = @[self]
  var chunks = newSeq[Rbst[T]]() # 親
  while rbsts.len > 0:
    let now = rbsts.pop()
    if now == nil : continue
    if now.right != nil:
      rbsts.add now.right
    if (including and now.key >= key) or (not including and now.key > key):
      if now.left != nil:
        rbsts.add now.left
      while chunks.len > 0 and now.key > chunks[^1].key:
        yield chunks.pop()
      chunks.add now
  while chunks.len > 0:
    yield chunks.pop()
iterator `>=`*[T](self:Rbst[T],key:T) : Rbst[T] =
  for v in self.greater(key,true): yield v
iterator `>`*[T](self:Rbst[T],key:T) : Rbst[T] =
  for v in self.greater(key,false): yield v
# キー以下のものを全て列挙(降順)
iterator less*[T](self:Rbst[T],key:T,including:bool) : Rbst[T] =
  var rbsts = @[self]
  var chunks = newSeq[Rbst[T]]() # 親
  while rbsts.len > 0:
    let now = rbsts.pop()
    if now == nil : continue
    if now.left != nil:
      rbsts.add now.left
    if (including and now.key <= key) or (not including and now.key < key):
      if now.right != nil:
        rbsts.add now.right
      while chunks.len > 0 and now.key < chunks[^1].key:
        yield chunks.pop()
      chunks.add now
  while chunks.len > 0:
    yield chunks.pop()
iterator `<=`*[T](self:Rbst[T],key:T) : Rbst[T] =
  for v in self.less(key,true): yield v
iterator `<`*[T](self:Rbst[T],key:T) : Rbst[T] =
  for v in self.less(key,false): yield v
# 一つだけ欲しい場合
proc findGreater*[T](self:Rbst[T],key:T,including:bool) : Rbst[T] =
  if self == nil: return nil
  if including and self.key == key: return self
  let r = self.left.findGreater(key,including)
  if r != nil: return r
  if self.key > key: return self
  return self.right.findGreater(key,including)
proc findLess*[T](self:Rbst[T],key:T,including:bool) : Rbst[T] =
  if self == nil: return nil
  if including and self.key == key: return self
  let r = self.right.findLess(key,including)
  if r != nil: return r
  if self.key < key: return self
  return self.left.findLess(key,including)

# 木自身(*.root以降)はイテレータとなっているので、そちらを操作するとより多くの情報が得られる
# こちらは情報をfilterすることで使いやすくしたもの
type RbstRoot*[T] = ref object
  # Rbstの根を指すラッパーを作成することで、いろいろな操作がしやすい.
  # 特に,自身は必ず nil ではないので操作がやりやすい.
  root*:Rbst[T]
  allowMulti*:bool
  count*:int
# コンストラクタ
proc newRbstRoot*[T](allowMulti:bool = true):RbstRoot[T] =
  result = RbstRoot[T](allowMulti:allowMulti)
# 挿入,削除,キー検索,要素数
proc erase*[T](self:var RbstRoot[T],key:T) : bool {.discardable.}=
  if self.root == nil : return
  result = self.root.erase(key)
  if result : self.count -= 1
proc len*[T](self:RbstRoot[T]) : int =
  if self.root == nil : return 0
  return self.count
proc contains*[T](self:RbstRoot[T],key:T):bool=
  if self.root == nil : return false
  return self.root.find(key) != nil
proc add*[T](self:var RbstRoot[T],key:T) =
  # 無ければ追加.とすることで擬似的に multiadd / add を切り替えられる(multiじゃないときはコストだが)
  if self.allowMulti:
    self.root.multiAdd(newRbst(key))
    self.count += 1
  elif self.root.singleAdd(newRbst(key)):
    self.count += 1
# 検索. 最小値,最大値
proc min*[T](self:RbstRoot[T]): T =
  return self.root.min().key
proc max*[T](self:RbstRoot[T]): T =
  return self.root.max().key
proc at*[T](self:RbstRoot[T]): Slice[T] = self.root.at()
# 全列挙(昇順 / 降順)
iterator items*[T](self:RbstRoot[T]) : T =
  if self.root != nil:
    for v in self.root:
      for _ in 0..<v.sameCount: yield v.key
iterator itemsDesc*[T](self:RbstRoot[T]) : T =
  if self.root != nil :
    for v in self.root.itemsDesc:
      for _ in 0..<v.sameCount: yield v.key
# キー以上のものを全て列挙(昇順)
iterator `>=`*[T](self:RbstRoot[T],key:T) : T =
  if self.root != nil :
    for v in self.root.greater(key,true):
      for _ in 0..<v.sameCount: yield v.key
iterator `>`*[T](self:RbstRoot[T],key:T) : T =
  if self.root != nil :
    for v in self.root.greater(key,false):
      for _ in 0..<v.sameCount: yield v.key
# キー以下のものを全て列挙(降順)
iterator `<=`*[T](self:RbstRoot[T],key:T) : T =
  if self.root != nil :
    for v in self.root.less(key,true):
      for _ in 0..<v.sameCount: yield v.key
iterator `<`*[T](self:RbstRoot[T],key:T) : T =
  if self.root != nil :
    for v in self.root.less(key,false):
      for _ in 0..<v.sameCount: yield v.key
proc dump*[T](self:RbstRoot[T]) : string = self.root.dump(0)
# 完全な平衡二分探索木を構築する.定数倍速いしこれからも速くなる.
{.checks:off.}
import math
proc makePerfectTree*[T](self:var RbstRoot[T],arr:seq[T]) =
  proc countTrailingZeroBits(x: culonglong): cint {.importc: "__builtin_ctzll", cdecl.}
  proc quickSortAt[T](arr:var seq[T], at:Slice[int],isDescending:bool = false) =
    if arr.len <= 1 : return
    var l = at.a
    var r = at.b
    let d = r - l + 1
    let ctlz = cast[culonglong](d).countTrailingZeroBits()
    if d > 16: #
      var s = 1 shl ctlz
      let l2 = 0.max(l + (r - s))
      while s >= d: s = s shr 1
      for i in s.countdown(0):
        swap arr[l+i], arr[l+randomBit(ctlz)]
      for i in s.countdown(0):
        swap arr[l2+i], arr[l2+randomBit(ctlz)]
    var ls = newSeq[int](ctlz+50)
    var rs = newSeq[int](ctlz+50)
    ls[0] = 0
    rs[0] = arr.len - 1
    var p = 1
    while p > 0:
      p -= 1
      var pl = ls[p]
      var pr = rs[p]
      var x = arr[(pl+pr) shr 1] # pivot
      l = pl
      r = pr
      var once = true
      while pl <= pr or once:
        while arr[pl] < x : pl += 1 # cmp
        while x < arr[pr] : pr -= 1 # cmp
        if pl <= pr:
          if pl < pr:
            swap arr[pl],arr[pr]
          pl += 1
          pr -= 1
        once = false
      if l < pr:
        ls[p] = l
        rs[p] = pr
        p += 1
      if pl < r:
        ls[p] = pl
        rs[p] = r
        p += 1
    if isDescending:
      for i in 0..<arr.len shr 1:
        swap arr[i] , arr[arr.len-1-i]
  proc quickSort[T](arr:var seq[T],isDescending:bool = false) =
    arr.quickSortAt(0..<arr.len,isDescending)
  self.root = nil
  self.count = 0
  if arr.len <= 0 : return
  var S = newSeq[T]()
  var counts = newSeq[int32]()
  var arr2 = arr
  arr2.quickSort()
  for a in arr2:
    if S.len > 0 and S[^1] == a :
      if self.allowMulti:
        counts[^1] += 1
      continue
    S.add a
    counts.add 1
  let n30 = 1 shl 30
  var interval = n30 div (10+S.len).nextPowerOfTwo()
  var rbsts = newSeq[Rbst[T]](S.len)
  for i in 0..<S.len:
    rbsts[i] = Rbst[T](key:S[i],sameCount:counts[i])
  proc impl(now:var Rbst[T],ri,si,offset:int) =
    if si < S.len and si >= 0:
      now = rbsts[si]
      now.priority = (n30 - ri * interval).int32
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
    var A = newRbstRoot[int]()
    for i in 0..<n: A.add randomBit(32)
    # for i in 0..<n:
    #   if randomBit(32) in A : x += 1
    echo x,":",A.len
when isMainModule:
  import unittest
  import sequtils
  test "Rbst":
    block:
      xorShiftVar = 88172645463325252.uint64
      for k in 0..<1:
        var A = newRbstRoot[int]()
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
