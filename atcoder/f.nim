# import nimprof
{.checks:off.}
import sequtils,algorithm,math,tables,sets,strutils,times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
template loop*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord



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
iterator greater*[T](self:Treap[T],key:T,including:bool) : Treap[T] =
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
  for v in self.greater(key,true): yield v
iterator `>`*[T](self:Treap[T],key:T) : Treap[T] =
  for v in self.greater(key,false): yield v
# キー以下のものを全て列挙(降順)
iterator less*[T](self:Treap[T],key:T,including:bool) : Treap[T] =
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
  for v in self.less(key,true): yield v
iterator `<`*[T](self:Treap[T],key:T) : Treap[T] =
  for v in self.less(key,false): yield v
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
    for v in self.root.greater(key,true):
      for _ in 0..<v.sameCount: yield v.key
iterator `>`*[T](self:TreapRoot[T],key:T) : T =
  if self.root != nil :
    for v in self.root.greater(key,false):
      for _ in 0..<v.sameCount: yield v.key
# キー以下のものを全て列挙(降順)
iterator `<=`*[T](self:TreapRoot[T],key:T) : T =
  if self.root != nil :
    for v in self.root.less(key,true):
      for _ in 0..<v.sameCount: yield v.key
iterator `<`*[T](self:TreapRoot[T],key:T) : T =
  if self.root != nil :
    for v in self.root.less(key,false):
      for _ in 0..<v.sameCount: yield v.key
proc dump*[T](self:TreapRoot[T]) : string = self.root.dump(0)
# 完全な平衡二分探索木を構築する.定数倍速いしこれからも速くなる.
import math
proc resetWith*[T](self:var TreapRoot[T],arr:seq[T]) =
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
  var R = newSeq[int32]((10+S.len).nextPowerOfTwo())
  var interval = (1 shl 30) div R.len
  for i in 0..<R.len: R[i] = (i * interval).int32
  var treaps = newSeq[Treap[T]](S.len)
  for i in 0..<S.len:
    treaps[i] = Treap[T](key:S[i],sameCount:counts[i])
  proc impl(now:var Treap[T],ri,si,offset:int) =
    if ri < R.len and si < S.len and si >= 0:
      now = treaps[si]
      now.priority = R[ri]
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

stopwatch:
  var S = newTreapRoot[int](true)
  # let n = 18
  let n = scan()
  let m = 1 shl n
  # var B = newSeq[int](m)
  # for i in 0..<m:B[i] = randomBit(30)
  # for i in 0..<m:B[i] = scan()
  # S.resetWith(B)
  # for b in B:S.add b
  m.loop: S.add scan()
  var parent = newSeq[int]()
  block:
    let last = S.max()
    parent.add last
    S.erase last
  n.loop:
    var child = newSeq[int]()
    for p in parent:
      # p未満のものを一つだけ削除する
      let last = S.root.findLess(p-1,true)
      if last == nil:
        quit "No",0
      child.add last.key
      S.erase last.key
    parent.add child
  echo "Yes"
