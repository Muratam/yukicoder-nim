# verified : https://atcoder.jp/contests/abc140/tasks/abc140_f

# RBST に セグツリを乗っけたもの. 重複不可.
# めっちゃ重たいけど必要になることあるのかな？
# 座標圧縮して{BIT,セグツリ}でいいはず.
# 必要な問題が出たらそれがverify用のコードになるのでそれで

#[
type Monoid*[V] = ref object
  apply:proc(x,y:V):V
  unit:V
type SegRBST*[K,V] = ref object
  key*: K
  value*,sum*:V
  count*: int32 # 自分を含む要素の和
  left*,right*: SegRBST[K,V] # (left: [-∞..key) / right: (key,∞))
  monoid*:Monoid[V]
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
proc dump[K,V](self:SegRBST[K,V],indent:int = 0,mark:string="^") : string =
  if self == nil : return ""
  result = "|".repeat(indent) & " " & mark & " " & ($self.key) & " - (" & $self.len & ")\n"
  result .add self.right.dump(indent+1,"<")
  result .add self.left.dump(indent+1,">")
proc len*[K,V](self:SegRBST[K,V]):int {.inline.} =
  if self == nil : 0
  else: self.count.int
proc update[K,V](self:SegRBST[K,V]) : SegRBST[K,V] {.discardable.} =
  if self == nil: return
  self.count = 0
  self.sum = self.monoid.unit
  if self.left != nil:
    self.count += self.left.count
    self.sum = self.left.sum
  self.count += 1
  self.sum = self.monoid.apply(self.sum,self.value)
  if self.right != nil:
    self.count += self.right.count
    self.sum = self.monoid.apply(self.sum,self.right.sum)
  return self
proc findOrSet[K,V](self:SegRBST[K,V],key:K,value:V) : bool =
  if self == nil : return false
  if self.key == key:
    self.value = value
    self.update()
    return true
  if key < self.key:
    if self.left == nil : return false
    result = self.left.findOrSet(key,value)
    self.update()
  else:
    if self.right == nil: return false
    result = self.right.findOrSet(key,value)
    self.update()
proc mergeImpl[K,V](left,right:SegRBST[K,V]) : SegRBST[K,V] =
  if left == nil: return right
  if right == nil : return left
  # 優先度が高い方を根にする
  if xorShift() mod cast[uint64](left.count + right.count) < cast[uint64](left.count):
    left.right = left.right.mergeImpl(right)
    return left.update()
  else:
    right.left = left.mergeImpl(right.left)
    return right.update()
proc toSegRBST*[K,V](key:K,value:V,monoid:Monoid[V]):SegRBST[K,V] =
  result = SegRBST[K,V](
    key:key,
    value:value,
    sum:value,
    count:1,
    monoid:monoid,
  )
proc split*[K,V](self:SegRBST[K,V],key:K): tuple[l,r:SegRBST[K,V]] =
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
# 検索・挿入・削除
proc find*[K,V](self:SegRBST[K,V],key:K) : SegRBST[K,V]=
  if self == nil : return nil
  if self.key == key: return self
  if key < self.key:
    if self.left == nil : return nil
    return self.left.find(key)
  else:
    if self.right == nil: return nil
    return self.right.find(key)
proc contains*[K,V](self:SegRBST[K,V],key:K):bool=
  if self == nil : false
  else: self.find(key) != nil
proc `[]=`*[K,V](self:var SegRBST[K,V],key:K,value:V) =
  if self == nil:
    self = key.toSegRBST()
  elif self.key == key:
    self.value = value
    self.update()
  else:
    # 遅いが平衡を保つためには仕方ない
    let found = self.findOrSet(key)
    if found: return
    let s = self.split(key)
    self = s.l.mergeImpl(key.toSegRBST()).mergeImpl(s.r)
proc addSingle*[K,V](self:var SegRBST[K,V],key: K): bool {.discardable.}=
  if self == nil:
    self = toSegRBST(key)
  elif key == self.key:
    return false
  else:
    let found = self.find(key)
    if found != nil: return false
    let s = self.split(key)
    self = toSegRBST(key)
    self.left = s.l
    self.right = s.r
    self.update()
  return true
proc erase*[K,V](self:var SegRBST[K,V],key:K) :bool {.discardable.} =
  if self == nil : return false
  # 自分にさようなら
  if self.key == key:
    self = self.left.mergeImpl(self.right)
    return true
  if key < self.key:
    if self.left == nil : return false
    result = self.left.erase(key)
    self.update()
  else:
    if self.right == nil : return false
    result = self.right.erase(key)
    self.update()
proc eraseAt*[K,V](self:SegRBST[K,V],slice:Slice[int]): SegRBST[K,V] =
  # 指定した [x..y] を O(logN)で 取り除く
  if self == nil : return nil
  var sl = self.split(slice.a)
  sl.l.erase(slice.a,true)
  var sr = self.split(slice.b)
  sr.r.erase(slice.b,true)
  return sl.l.mergeImpl(sr.r)

# 要素数・最小値・最大値・範囲
proc min*[K,V](self:SegRBST[K,V]) : SegRBST[K,V] =
  if self == nil : return nil
  if self.left == nil: return self
  return self.left.min()
proc max*[K,V](self:SegRBST[K,V]) : SegRBST[K,V] =
  if self == nil : return nil
  if self.right == nil: return self
  return self.right.max()
proc at*[K,V](self:SegRBST[K,V]): Slice[K] =
  assert self != nil
  if self.left == nil : result.a = self.key
  else: result.a = self.min().key
  if self.right == nil: result.b = self.key
  else: result.b = self.max().key
# {昇順,降順}に全列挙 (自身を含む)
iterator items*[K,V](self:SegRBST[K,V]) : SegRBST[K,V] =
  if self != nil:
    var rbsts = @[self]
    var chunks = newSeq[SegRBST[K,V]]() # 親
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
iterator itemsDesc*[K,V](self:SegRBST[K,V]) : SegRBST[K,V] =
  if self != nil:
    var rbsts = @[self]
    var chunks = newSeq[SegRBST[K,V]]() # 親
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
proc `$`[K,V](self:SegRBST[K,V]):string = $toSeq(self.items).mapIt(it.key)
# キー以上のものを昇順に{一つ取得,全列挙}. 同じ要素はまとまっているので注意！
proc findGreater*[K,V](self:SegRBST[K,V],key:K,including:bool) : SegRBST[K,V] =
  if self == nil: return nil
  if including and self.key == key: return self
  let r = self.left.findGreater(key,including)
  if r != nil: return r
  if self.key > key: return self
  return self.right.findGreater(key,including)
iterator greater*[K,V](self:SegRBST[K,V],key:K,including:bool) : SegRBST[K,V] =
  if self != nil:
    var rbsts = @[self]
    var chunks = newSeq[SegRBST[K,V]]() # 親
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
iterator `>=`*[K,V](self:SegRBST[K,V],key:K) : SegRBST[K,V] =
  if self != nil:
    for v in self.greater(key,true): yield v
iterator `>`*[K,V](self:SegRBST[K,V],key:K) : SegRBST[K,V] =
  if self != nil:
    for v in self.greater(key,false): yield v
# キー以下のものを降順に{一つ取得,全列挙}. 同じ要素はまとまっているので注意！
proc findLess*[K,V](self:SegRBST[K,V],key:K,including:bool) : SegRBST[K,V] =
  if self == nil: return nil
  if including and self.key == key: return self
  let r = self.right.findLess(key,including)
  if r != nil: return r
  if self.key < key: return self
  return self.left.findLess(key,including)
iterator less*[K,V](self:SegRBST[K,V],key:K,including:bool) : SegRBST[K,V] =
  if self != nil:
    var rbsts = @[self]
    var chunks = newSeq[SegRBST[K,V]]() # 親
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
iterator `<=`*[K,V](self:SegRBST[K,V],key:K) : SegRBST[K,V] =
  if self != nil:
    for v in self.less(key,true): yield v
iterator `<`*[K,V](self:SegRBST[K,V],key:K) : SegRBST[K,V] =
  if self != nil:
    for v in self.less(key,false): yield v
# (小さい方から)k番目(0-index)のキー取得
proc findKth*[K,V](self:SegRBST[K,V],k:int): SegRBST[K,V] =
  if self == nil : return nil
  let llen = self.left.len
  if llen + self.sameCount <= k:
    return self.right.findKth(k - self.sameCount - llen)
  if k < llen : return self.left.findKth(k)
  return self
# あるキーが何番目(0-index)のキーなのか
proc isKth*[K,V](self:SegRBST[K,V],key:K): Slice[int] =
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
proc merge*[K,V](x,y:SegRBST[K,V]): SegRBST[K,V] =
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
  test "SegRBST":
    var R = newSegRBST[int]()
    let RI = @[0,0,1,1,1,2,3,4,4,4,5,6,7,7,8,8,9]
    for i in RI: R.add i
    # for i in 0..<100: R.add i
    for i in -2..10:
      echo i,":",R.isKth(i)
    var L = newSegRBST[int]()
    let LI = @[0,0,1,1,1,2,3,4,4,4,5,6,8,8,9]
    for i in LI: L.add i + 10
    for i in -2..20:
      let found = L.findKth(i)
      if found != nil:
        echo i,":",found.key
    echo R
    echo L
    let S = R.merge(L)
    echo S
    let (S1,S2) = S.split(15)
    echo S1
    echo S2
    echo S1.eraseAt(4..11)
    echo S1.dump()
]#
