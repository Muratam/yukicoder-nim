# verified : https://atcoder.jp/contests/abc140/tasks/abc140_f

# Randomized Binary Search Tree
# Treap ＋ split・merge・kth.
# Treapより2~3倍遅いが,buildRBST可能ならstd::mapより速い.
# 生の木を扱う書き方なので,都合に応じて使い分ける.
# 要素の重複が不許可 => singleAdd

type Rbst*[T] = ref object
  key*: T
  count*: int32 # 自分を含む要素の和
  left*,right*: Rbst[T] # (left: [-∞..key) / right: (key,∞))
  sameCount*:int32 # 自身と同一の要素数
import sequtils,math,times,algorithm,strutils
var xorShiftVar* = 88172645463325252.uint64
xorShiftVar = cast[uint64](cpuTime()) # 初期値を固定しない場合
proc xorShift() : uint64 =
  xorShiftVar = xorShiftVar xor (xorShiftVar shl 13)
  xorShiftVar = xorShiftVar xor (xorShiftVar shr 7)
  xorShiftVar = xorShiftVar xor (xorShiftVar shl 17)
  return xorShiftVar
proc randomBit(maxBit:int):int =
  cast[int](xorShift() and cast[uint64]((1 shl maxBit) - 1))
proc dump[T](self:Rbst[T],indent:int = 0,mark:string="^") : string =
  if self == nil : return ""
  result = "|".repeat(indent) & " " & mark & " " & ($self.key) & " (x" & $self.sameCount & ") - (" & $self.len & ")\n"
  result .add self.right.dump(indent+1,"<")
  result .add self.left.dump(indent+1,">")
proc len*[T](self:Rbst[T]):int {.inline.} =
  if self == nil : 0
  else: self.count.int
proc update[T](self:Rbst[T]) : Rbst[T] {.discardable.} =
  if self == nil: return
  self.count = self.sameCount
  if self.left != nil: self.count += self.left.count
  if self.right != nil: self.count += self.right.count
  return self
proc findOrAdd[T](self:Rbst[T],key:T) : bool =
  if self == nil : return false
  if self.key == key:
    self.sameCount += 1
    self.update()
    return true
  if key < self.key:
    if self.left == nil : return false
    result = self.left.findOrAdd(key)
    self.update()
  else:
    if self.right == nil: return false
    result = self.right.findOrAdd(key)
    self.update()
proc mergeImpl[T](left,right:Rbst[T]) : Rbst[T] =
  if left == nil: return right
  if right == nil : return left
  # 優先度が高い方を根にする
  if xorShift() mod cast[uint64](left.count + right.count) < cast[uint64](left.count):
    left.right = left.right.mergeImpl(right)
    return left.update()
  else:
    right.left = left.mergeImpl(right.left)
    return right.update()
# 構築
proc newRbst*[T]():Rbst[T] = nil
proc toRbst*[T](key:T):Rbst[T] =
  result = Rbst[T](
    key:key,
    sameCount:1,
    count:1,
  )
proc split*[T](self:Rbst[T],key:T): tuple[l,r:Rbst[T]] =
  # 再帰的に切るだけ. (子は必ず優先度が低いので)
  if self == nil: return (nil,nil)
  if key < self.key:
    let s = self.left.split(key)
    self.left = s.r
    return (s.l,self.update())
  else:
    let s = self.right.split(key)
    self.right = s.l
    return (self.update(),s.r)
# 検索・重複{あり,なし}挿入・削除
proc find*[T](self:Rbst[T],key:T) : Rbst[T]=
  if self == nil : return nil
  if self.key == key: return self
  if key < self.key:
    if self.left == nil : return nil
    return self.left.find(key)
  else:
    if self.right == nil: return nil
    return self.right.find(key)
proc contains*[T](self:Rbst[T],key:T):bool=
  if self == nil : false
  else: self.find(key) != nil
proc add*[T](self:var Rbst[T],key:T) =
  if self == nil:
    self = key.toRbst()
  elif self.key == key:
    self.sameCount += 1
    self.update()
  else:
    # 遅いが平衡を保つためには仕方ない
    let found = self.findOrAdd(key)
    if found: return
    let s = self.split(key)
    self = s.l.mergeImpl(key.toRbst()).mergeImpl(s.r)
proc addSingle*[T](self:var Rbst[T],key: T): bool {.discardable.}=
  if self == nil:
    self = toRbst(key)
  elif key == self.key:
    return false
  else:
    let found = self.find(key)
    if found != nil: return false
    let s = self.split(key)
    self = toRbst(key)
    self.left = s.l
    self.right = s.r
    self.update()
  return true
proc erase*[T](self:var Rbst[T],key:T,all:bool = false) :bool {.discardable.} =
  if self == nil : return false
  # 自分にさようなら
  if self.key == key:
    if not all and self.sameCount > 1:
      self.sameCount -= 1
      self.update()
    else:
      self = self.left.mergeImpl(self.right)
    return true
  if key < self.key:
    if self.left == nil : return false
    result = self.left.erase(key,all)
    self.update()
  else:
    if self.right == nil : return false
    result = self.right.erase(key,all)
    self.update()
proc eraseAt*[T](self:Rbst[T],slice:Slice[int]): Rbst[T] =
  # 指定した [x..y] を O(logN)で 取り除く
  if self == nil : return nil
  var sl = self.split(slice.a)
  sl.l.erase(slice.a,true)
  var sr = self.split(slice.b)
  sr.r.erase(slice.b,true)
  return sl.l.mergeImpl(sr.r)

# 要素数・最小値・最大値・範囲
proc min*[T](self:Rbst[T]) : Rbst[T] =
  if self == nil : return nil
  if self.left == nil: return self
  return self.left.min()
proc max*[T](self:Rbst[T]) : Rbst[T] =
  if self == nil : return nil
  if self.right == nil: return self
  return self.right.max()
proc at*[T](self:Rbst[T]): Slice[T] =
  assert self != nil
  if self.left == nil : result.a = self.key
  else: result.a = self.min().key
  if self.right == nil: result.b = self.key
  else: result.b = self.max().key
# {昇順,降順}に全列挙 (自身を含む)
iterator items*[T](self:Rbst[T]) : Rbst[T] =
  if self != nil:
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
iterator itemsDesc*[T](self:Rbst[T]) : Rbst[T] =
  if self != nil:
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
proc `$`[T](self:Rbst[T]):string = $toSeq(self.items).mapIt(it.key)
# キー以上のものを昇順に{一つ取得,全列挙}. 同じ要素はまとまっているので注意！
proc findGreater*[T](self:Rbst[T],key:T,including:bool) : Rbst[T] =
  if self == nil: return nil
  if including and self.key == key: return self
  if self.key < key:
    return self.right.findGreater(key,including)
  let r = self.left.findGreater(key,including)
  if r != nil: return r
  if self.key > key: return self
  return self.right.findGreater(key,including)
iterator greater*[T](self:Rbst[T],key:T,including:bool) : Rbst[T] =
  if self != nil:
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
# キー以下のものを降順に{一つ取得,全列挙}. 同じ要素はまとまっているので注意！
proc findLess*[T](self:Rbst[T],key:T,including:bool) : Rbst[T] =
  if self == nil: return nil
  if including and self.key == key: return self
  if self.key > key:
    return self.left.findLess(key,including)
  let r = self.right.findLess(key,including)
  if r != nil: return r
  if self.key < key: return self
  return self.left.findLess(key,including)
iterator less*[T](self:Rbst[T],key:T,including:bool) : Rbst[T] =
  if self != nil:
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
# 完全な平衡二分探索木を構築する.定数倍速いしこれからも速くなる.
{.checks:off.}
import algorithm
proc buildRBST*[T](arr:seq[T],allowMulti:bool = true) : Rbst[T] =
  if arr.len <= 0 : return
  var S = newSeq[T]()
  var counts = newSeq[int32]()
  var arr2 = arr.sorted()
  for a in arr2:
    if S.len > 0 and S[^1] == a :
      if allowMulti: counts[^1] += 1
      continue
    S.add a
    counts.add 1
  var rbsts = newSeq[Rbst[T]](S.len)
  for i in 0..<S.len:
    rbsts[i] = Rbst[T](key:S[i],sameCount:counts[i])
  proc impl(now:var Rbst[T],si,offset:int) =
    if si < S.len and si >= 0:
      now = rbsts[si]
    if offset != 0 :
      if now == nil:
        now.impl(si-offset,offset shr 1)
      else:
        now.left.impl(si-offset,offset shr 1)
        now.right.impl(si+offset,offset shr 1)
  let offset = (S.len + 2).nextPowerOfTwo() shr 2
  let mid = offset * 2 - 1
  result.impl(mid,offset)
  proc updateCount(now:var Rbst[T])  : int =
    if now == nil: return 0
    now.count = int32(
      now.left.updateCount() +
      now.right.updateCount() +
      now.sameCount)
    return now.count.int
  discard updateCount(result)

# 以下 RBST の機能 ----------------------------------------
# (小さい方から)k番目(0-index)のキー取得
proc findKth*[T](self:Rbst[T],k:int): Rbst[T] =
  if self == nil : return nil
  let llen = self.left.len
  if llen + self.sameCount <= k:
    return self.right.findKth(k - self.sameCount - llen)
  if k < llen : return self.left.findKth(k)
  return self
# あるキーが何番目(0-index)のキーなのか
proc isKth*[T](self:Rbst[T],key:T): Slice[int] =
  if self == nil : return -1.. -1
  if self.key == key :
    return self.left.len..self.left.len+self.sameCount-1
  if key < self.key:
    if self.left == nil : return -1.. -1
    return self.left.isKth(key)
  if self.right == nil : return -1.. -1
  let llen = self.left.len + self.sameCount
  let r = self.right.isKth(key)
  return llen+r.a..llen+r.b
# 範囲がかぶっていない場合のマージ.マージしたら前の木は使えない.
proc merge*[T](x,y:Rbst[T]): Rbst[T] =
  if x == nil : return y
  if y == nil : return x
  let xAt = x.at
  let yAt = y.at
  if xAt.b < yAt.a: return x.mergeImpl(y)
  if yAt.b < xAt.a: return y.mergeImpl(x)
  echo "範囲がかぶっているmergeはできないね！"
  echo "できてもO(範囲の中の個数)かかるよ！ "
  doAssert false

import times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
when isMainModule:
  import unittest
  import sequtils
  test "Rbst":
    var R = newRbst[int]()
    let RI = @[0,0,1,1,1,2,3,4,4,4,5,6,7,7,8,8,9]
    for i in RI: R.add i
    # for i in 0..<100: R.add i
    # for i in -2..10:
    #   echo i,":",R.isKth(i)
    # var L = newRbst[int]()
    # let LI = @[0,0,1,1,1,2,3,4,4,4,5,6,8,8,9]
    # for i in LI: L.add i + 10
    # for i in -2..20:
    #   let found = L.findKth(i)
    #   if found != nil:
    #     echo i,":",found.key
    # echo R
    # echo L
    # let S = R.merge(L)
    # echo S
    # let (S1,S2) = S.split(15)
    # echo S1
    # echo S2
    # echo S1.eraseAt(4..11)
    # echo S1.dump()
