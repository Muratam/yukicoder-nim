# 参考 : https://www.slideshare.net/iwiwi/2-12188757
# verified : https://atcoder.jp/contests/abc140/tasks/abc140_f

# Treap
# std::{,multi}set の代替.
# key には int以外のカスタムの比較関数も取れる
# 平衡度が緩いため,std::map の2~3倍遅い.
# 要素が先に分かっている場合は完全な平衡木を作れてstd::mapより速くなる.

import sequtils
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
proc merge[T](left,right:Treap[T]) : Treap[T] =
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
proc split[T](self:Treap[T],key:T): tuple[l,r:Treap[T]] =
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
proc find[T](self:Treap[T],key:T) : Treap[T]=
  if self == nil : return nil
  if self.key == key: return self
  if key < self.key:
    if self.left == nil : return nil
    return self.left.find(key)
  else:
    if self.right == nil: return nil
    return self.right.find(key)
proc singleAdd[T](self:var Treap[T],item: Treap[T]): bool {.discardable.}=
  if self == nil:
    self = item
  elif item.key == self.key:
    return false
  elif item.priority > self.priority:
    let found = self.find(item.key)
    if found != nil: return false
    let s = self.split(item.key)
    self = item
    self.left = s.l
    self.right = s.r
  elif item.key < self.key:
    return self.left.singleAdd(item)
  else:
    return self.right.singleAdd(item)
  return true
proc multiAdd[T](self:var Treap[T],item: Treap[T]) =
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
proc erase[T](self:var Treap[T],key:T,all:bool=false) :bool {.discardable.} =
  # 自分にさようなら
  if self.key == key:
    if not all and self.sameCount > 1:
      self.sameCount -= 1
    else:
      self = self.left.merge(self.right)
    return true
  elif key < self.key:
    if self.left == nil : return false
    result = self.left.erase(key,all)
  else:
    if self.right == nil : return false
    result = self.right.erase(key,all)
iterator items[T](self:Treap[T]) : Treap[T] =
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
iterator itemsDesc[T](self:Treap[T]) : Treap[T] =
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
iterator greater[T](self:Treap[T],key:T,including:bool) : Treap[T] =
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
iterator less[T](self:Treap[T],key:T,including:bool) : Treap[T] =
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
proc min[T](self:Treap[T]) : Treap[T] =
  if self == nil : return nil
  if self.left == nil: return self
  return self.left.min()
proc max[T](self:Treap[T]) : Treap[T] =
  if self == nil : return nil
  if self.right == nil: return self
  return self.right.max()
proc at[T](self:Treap[T]): Slice[T] =
  if self == nil : return nil
  if self.left == nil : result.a = self.key
  else: result.a = self.min()
  if self.right == nil: result.b = self.key
  else: result.b = self.max()
proc findGreater[T](self:Treap[T],key:T,including:bool) : Treap[T] =
  if self == nil: return nil
  if including and self.key == key: return self
  if self.key < key:
    return self.right.findGreater(key,including)
  let l = self.left.findGreater(key,including)
  if l != nil: return l
  if self.key > key: return self
  return self.right.findGreater(key,including)
proc findLess[T](self:Treap[T],key:T,including:bool) : Treap[T] =
  if self == nil: return nil
  if including and self.key == key: return self
  if self.key > key:
    return self.left.findLess(key,including)
  let r = self.right.findLess(key,including)
  if r != nil: return r
  if self.key < key: return self
  return self.left.findLess(key,including)
proc eraseAt[T](self:Treap[T],slice:Slice[int]): Treap[T] =
  # 指定した [x..y] を O(logN)で 取り除く
  if self == nil : return nil
  var sl = self.split(slice.a)
  sl.l.erase(slice.a,true)
  var sr = self.split(slice.b)
  sr.r.erase(slice.b,true)
  return sl.l.merge(sr.r)

# 集合のキーのみに着目して操作するもの.
type TreapSet*[T] = ref object
  # Treapの根を指すラッパーを作成することで、いろいろな操作がしやすい.
  # 特に,自身は必ず nil ではないので操作がやりやすい.
  root*:Treap[T]
  allowMulti*:bool
  count*:int
proc newTreapSet*[T](allowMulti:bool = true):TreapSet[T] =
  result = TreapSet[T](allowMulti:allowMulti)
proc dump*[T](self:TreapSet[T]) : string = self.root.dump(0)
# 挿入・削除・要素数・範囲削除
proc add*[T](self:var TreapSet[T],key:T) =
  # 無ければ追加.とすることで擬似的に multiadd / add を切り替えられる(multiじゃないときはコストだが)
  if self.allowMulti:
    self.root.multiAdd(newTreap(key))
    self.count += 1
  elif self.root.singleAdd(newTreap(key)):
    self.count += 1
proc erase*[T](self:var TreapSet[T],key:T) : bool {.discardable.}=
  if self.root == nil : return
  result = self.root.erase(key)
  if result : self.count -= 1
proc len*[T](self:TreapSet[T]) : int =
  if self.root == nil : return 0
  return self.count
proc eraseAt*[T](self:TreapSet[T],slice:Slice[int]) =
  self.root.eraseAt(slice)
# 検索・範囲・最小値・最大値・境界
proc contains*[T](self:TreapSet[T],key:T):bool=
  if self.root == nil : return false
  return self.root.find(key) != nil
proc at*[T](self:TreapSet[T]): Slice[T] = self.root.at()
proc min*[T](self:TreapSet[T]): T =
  return self.root.min().key
proc max*[T](self:TreapSet[T]): T =
  return self.root.max().key
proc findGreater*[T](self:TreapSet[T],key:T,including:bool) : tuple[ok:bool,val:T] =
  let found = self.root.findGreater(key,including)
  if found != nil:
    result.ok = true
    result.val = found.key
proc findLess*[T](self:TreapSet[T],key:T,including:bool) : tuple[ok:bool,val:T] =
  let found = self.root.findLess(key,including)
  if found != nil:
    result.ok = true
    result.val = found.key
# 全列挙(昇順{全,以上} / 降順{全,以下})
iterator items*[T](self:TreapSet[T]) : T =
  if self.root != nil:
    for v in self.root.items:
      for _ in 0..<v.sameCount: yield v.key
iterator itemsDesc*[T](self:TreapSet[T]) : T =
  if self.root != nil :
    for v in self.root.itemsDesc:
      for _ in 0..<v.sameCount: yield v.key
iterator `>=`*[T](self:TreapSet[T],key:T) : T =
  if self.root != nil :
    for v in self.root.greater(key,true):
      for _ in 0..<v.sameCount: yield v.key
iterator `>`*[T](self:TreapSet[T],key:T) : T =
  if self.root != nil :
    for v in self.root.greater(key,false):
      for _ in 0..<v.sameCount: yield v.key
iterator `<=`*[T](self:TreapSet[T],key:T) : T =
  if self.root != nil :
    for v in self.root.less(key,true):
      for _ in 0..<v.sameCount: yield v.key
iterator `<`*[T](self:TreapSet[T],key:T) : T =
  if self.root != nil :
    for v in self.root.less(key,false):
      for _ in 0..<v.sameCount: yield v.key
proc `$`*[T](self:TreapSet[T]):string = $toSeq(self.items)
# 完全な平衡二分探索木を構築する.全てが2倍くらい速くなる.
{.checks:off.}
import math
proc resetWith*[T](self:var TreapSet[T],arr:seq[T]) =
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
  var treaps = newSeq[Treap[T]](S.len)
  for i in 0..<S.len:
    treaps[i] = Treap[T](key:S[i],sameCount:counts[i])
  proc impl(now:var Treap[T],ri,si,offset:int) =
    if si < S.len and si >= 0:
      now = treaps[si]
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
when isMainModule:
  let n = 1e6.int
  stopwatch:
    var A = newTreapSet[int]()
    # for i in 0..<100: A.add i
    # echo A.dump()

    # for i in 0..<n: A.add randomBit(32)
    # for i in 0..<n:
    #   if randomBit(32) in A : x += 1
    # echo x,":",A.len
when isMainModule:
  import unittest
  import sequtils
  test "Treap":
    block:
      xorShiftVar = 88172645463325252.uint64
      for k in 0..<1:
        var A = newTreapSet[int]()
        for i in 0..<20:
          A.add randomBit(5)
        # echo A.min()
        # echo A.max()
        # echo A
        # echo toSeq(A.items)
        # echo toSeq(A.itemsDesc)
        # let n = 18
        # echo toSeq(A >= n)
        # echo toSeq(A > n)
        # let x = toSeq(A < n)
        # echo x
        # echo toSeq(A <= n)
        # for xi in 1..<x.len:
        #   if x[xi-1] < x[xi] :
        #     echo x
        #     echo A
        #     quit 0
        # for i in 0..<10:
        #   A.erase randomBit(5)
