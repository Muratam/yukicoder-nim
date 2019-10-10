# https://www.slideshare.net/iwiwi/2-12188757
# Treap : 区間木 + 動的木, 定数倍は重い.
# 0. key: min,max,find,add,erase,iter,kth
#    value: RMQ(1点更新/区間モノイド)
# 1. key には int以外のカスタムの比較関数も取れる
# 2. 区間の Split / Merge ができる.
# 3. 素な区間に対するモノイドができる.
# 4. カスタムの木の操作をしたい場合, 書きやすい.
# 5. 木の構築時の平衡性しか問題ではないので,実装を赤黒木など別のものに差し替えやすい.

import "../../mathlib/random"
import sequtils
# 余分な葉が無いので半群(モノイドに比べて単位元が不要)でよい
type SemiGroup*[V] = proc(x,y:V):V
type Treap*[K,V] = ref object
  key*: K
  priority*: int32
  left*,right*: Treap[K,V] # left: [-∞..key) / right: [key,∞)
  count*:int32 # k番目の最小を取るために必要.
  when V isnot void:
    value*,sum*: V
    apply*:SemiGroup[V] # 全員が持つのはちょっと無駄かも(あまり変わらないが)
proc newTreap*[K](key:K):Treap[K,void] =
  result = Treap[K,void](
    key:key,
    priority:randomBit(30).int32,
    count:1,
  )
proc newTreap*[K,V](apply:SemiGroup[V],key:K,value:V):Treap[K,V] =
  result = Treap[K,V](
    key:key,
    priority:randomBit(30).int32,
    count:1,
    value:value,
    sum:value,
    apply:apply
  )
proc len[K,V](self:Treap[K,V]) : int32 =
  if self == nil: 0 else: self.count
proc update[V:not void,K](self:Treap[K,V]) =
  self.count = self.left.len + 1 + self.right.len
  self.sum = self.value
  if self.left != nil: self.sum = self.apply(self.left.sum,self.sum)
  if self.right != nil: self.sum = self.apply(self.sum,self.right.sum)
proc update[K](self:Treap[K,void]) {.inline.} =
  self.count = self.left.len + 1 + self.right.len
# merge / split
proc merge*[K,V](left,right:Treap[K,V]) : Treap[K,V] =
  # 必ず ∀[left] < ∀[right] の時に呼ばれるという仮定を置いている
  if left == nil: return right
  if right == nil : return left
  # 優先度が高い方を根にする
  if left.priority > right.priority:
    left.right = left.right.merge(right)
    left.update()
    return left
  else:
    right.left = left.merge(right.left)
    right.update()
    return right
proc split*[K,V](self:Treap[K,V],key:K): tuple[l,r:Treap[K,V]] =
  # 再帰的に切るだけ. (子は必ず優先度が低いので)
  if self == nil: return (nil,nil)
  if key < self.key:
    let s = self.left.split(key)
    self.left = s.r
    self.update()
    return (s.l,self)
  else:
    let s = self.right.split(key)
    self.right = s.l
    self.update()
    return (self,s.r)
# 挿入・削除
proc add*[K,V](self:var Treap[K,V],item: Treap[K,V]) =
  if self == nil:
    self = item
    return
  if item.priority > self.priority:
    let s = self.split(item.key)
    item.left = s.l
    item.right = s.r
    self = item
  elif item.key < self.key:
    self.left.add(item)
  else:
    self.right.add(item)
  self.update()
proc excl*[K,V](self:var Treap[K,V],key:K) :bool {.discardable.} =
  # 自分にさようなら
  if self.key == key:
    self = self.left.merge(self.right)
    return true
  elif key < self.key:
    if self.left == nil : return false
    result = self.left.excl(key)
  else:
    if self.right == nil : return false
    result = self.right.excl(key)
  when V isnot void : self.update()
# セグツリ
proc `[]`*[V:not void,K](self:Treap[K,V],at:Slice[K]):V =
  # 単位元は不要！
  # assert at.a <= self.key and self.key <= at.b
  if self.left != nil:


# キー検索
# 一致,最小値,最大値
proc findByKey*[K,V](self:Treap[K,V],key:K) : Treap[K,V]=
  if self.key == key: return self
  if key < self.key:
    if self.left == nil : return nil
    return self.left.findByKey(key)
  else:
    if self.right == nil: return nil
    return self.right.findByKey(key)
proc findMinKey*[K,V](self:Treap[K,V]) : Treap[K,V] =
  if self.left == nil: return self
  return self.left.findMin()
proc findMaxKey*[K,V](self:Treap[K,V]) : Treap[K,V] =
  if self.right == nil: return self
  return self.right.findMax()
# (小さい方から)k番目(0-index)のキー取得
proc findKth*[V,K](self:Treap[K,V],k:int): Treap[K,V] =
  if self == nil : return nil
  # 最適化のためにvoid型では不可能になっている(自身が個数を持っていないので)
  let llen = self.left.len
  if llen == k : return self
  if llen > k : return self.left.findKth(k)
  return self.right.findKth(k - 1 - llen)
# あるキーが何番目(0-index)のキーなのか
proc isKth*[V,K](self:Treap[K,V],key:K): int =
  # 同じキーに複数のnthの可能性がある場合はどれになるかは不明
  if self == nil : return -1
  if self.key == key : return self.left.len
  if key < self.key:
    if self.left == nil : return -1
    return self.left.isKth(key)
  if self.right == nil : return -1
  return self.left.len + 1 + self.left.isKth(key)
# 列挙
# 自身を含むノードを全て列挙(昇順)
iterator items*[K,V](self:Treap[K,V]) : Treap[K,V] =
  var treaps = @[(self,true)]
  while treaps.len > 0:
    let (now,needLeft) = treaps.pop()
    if not needLeft or now.left == nil:
      yield now
      if now.right != nil:
        treaps.add((now.right,true))
    else:
      treaps.add((now,false))
      treaps.add((now.left,true))
# 自身を含むノードを全て列挙(降順)
iterator itemsDesc*[K,V](self:Treap[K,V]) : Treap[K,V] =
  var treaps = @[(self,true)]
  while treaps.len > 0:
    let (now,needRight) = treaps.pop()
    if not needRight or now.right == nil:
      yield now
      if now.left != nil:
        treaps.add((now.left,true))
    else:
      treaps.add((now,false))
      treaps.add((now.right,true))
# キー以上のものを全て列挙(昇順)
iterator over*[K,V](self:Treap[K,V],key:K,including:bool) : Treap[K,V] =
  var treaps = @[(self,true)]
  while treaps.len > 0:
    let (now,needLeft) = treaps.pop()
    if key > now.key:
      if including and key == now.key : yield now
      if now.left != nil:
        treaps.add((now.right,true))
    elif not needLeft or now.left == nil:
      if including and key <= now.key : yield now
      elif key < now.key: yield now
      if now.right != nil:
        treaps.add((now.right,true))
    else:
      treaps.add((now,false))
      treaps.add((now.left,true))
# キー以下のものを全て列挙(降順)
iterator under*[K,V](self:Treap[K,V],key:K,including:bool) : Treap[K,V] =
  var treaps = @[(self,true)]
  while treaps.len > 0:
    let (now,needRight) = treaps.pop()
    if key < now.key:
      if including and key == now.key : yield now
      if now.left != nil:
        treaps.add((now.left,true))
    elif not needRight or now.right == nil:
      if including and key >= now.key : yield now
      elif key > now.key: yield now
      if now.left != nil:
        treaps.add((now.left,true))
    else:
      treaps.add((now,false))
      treaps.add((now.right,true))


# Treapの根を指すラッパーを作成することで、いろいろな操作がしやすい.
# 特に,自身は必ず nil ではないので操作がやりやすい.
# 木自身(*.root以降)はイテレータとなっているので、そちらを操作するとより多くの情報が得られる
type TreapRoot*[K,V] = ref object
  root*:Treap[K,V]
  multiAdd*:bool
  when V isnot void:
    apply*:SemiGroup[V]
  when V is void:
    count*:int
# コンストラクタ
proc newTreapRoot*[K](multiAdd:bool = true):TreapRoot[K,void] =
  result = TreapRoot[K,void](multiAdd:multiAdd)
proc newTreapRoot*[K,V](apply:SemiGroup[V]):TreapRoot[K,V] =
  result = TreapRoot[K,V](apply:apply,multiAdd:false)
# どこかで見つけた部分木(*.rootを中心にイテレータを回して取る)を根にする
proc toRoot*[K](self:TreapRoot[K,void],treap:Treap[K,void]):TreapRoot[K,void] =
  result = TreapRoot[K,void](
    multiAdd:self.multiAdd,
    root:treap
  )
proc toRoot*[K,V](self:TreapRoot[K,V],treap:Treap[K,V]):TreapRoot[K,V] =
  result = TreapRoot[K,V](
    apply:self.apply,
    multiAdd:self.multiAdd,
    root:treap
  )
# 基本操作
proc excl*[K,V](self:var TreapRoot[K,V],key:K) : bool {.discardable.}=
  if self.root == nil : return
  result = self.root.excl(key)
  when V is void:
    if result : self.count -= 1
proc len*[K,V](self:TreapRoot[K,V]) : int =
  if self.root == nil : return 0
  else:
    when V is void: return self.count
    else: return self.root.len
proc contains*[K,V](self:TreapRoot[K,V],key:K):bool=
  if self.root == nil : return false
  return self.root.findByKey(key) != nil
proc `add`*[K](self:var TreapRoot[K,void],key:K) =
  # 無ければ追加.とすることで擬似的に multiadd / add を切り替えられる(multiじゃないときはコストだが)
  if not self.multiAdd and key in self: return
  self.root.add(newTreap(key))
  self.count += 1
proc `[]=`*[V:not void,K](self:var TreapRoot[K,V],key:K,value:V) =
  # 無ければ追加.とすることで擬似的に multiadd / add を切り替えられる(multiじゃないときはコストだが)
  if not self.multiAdd and key in self: return
  self.root.add(newTreap(self.apply,key,value))
proc `[]`*[V:not void,K](self:TreapRoot[K,V],key:K): V =
  assert self.root != nil
  let found = self.root.findByKey(key)
  assert found != nil
  return found.value
# 検索
# type Result[K,V] =
#   when V is void: tuple[k:K,v:V]
#   else: K
proc findMinKey*[K](self:TreapRoot[K,void]):K=
  assert self.root != nil
  return self.root.findMinKey().key
proc findMaxKey*[K](self:TreapRoot[K,void]):K=
  assert self.root != nil
  return self.root.findMaxKey().key
iterator items*[K](self:TreapRoot[K,void]) : K =
  if self.root != nil :
    for v in self.root: yield v.key
iterator itemsDesc*[K](self:TreapRoot[K,void]) : K =
  if self.root != nil :
    for v in self.root.itemsDesc: yield v.key
iterator `<=`*[K](self:TreapRoot[K,void],key:K) : K =
  if self.root != nil :
    for v in self.root.under(key,true): yield v.key
iterator `<`*[K](self:TreapRoot[K,void],key:K) : K =
  if self.root != nil :
    for v in self.root.under(key,false): yield v.key
iterator `>=`*[K](self:TreapRoot[K,void],key:K) : K =
  if self.root != nil :
    for v in self.root.over(key,true): yield v.key
iterator `>`*[K](self:TreapRoot[K,void],key:K) : K =
  if self.root != nil :
    for v in self.root.over(key,false): yield v.key
iterator items*[V:not void,K](self:TreapRoot[K,V]) : tuple[k:K,v:V] =
  if self.root != nil :
    for v in self.root: yield (v.key,v.value)
iterator itemsDesc*[V:not void,K](self:TreapRoot[K,V]) : tuple[k:K,v:V] =
  if self.root != nil :
    for v in self.root.itemsDesc: yield (v.key,v.value)
# proc findKth*[K,V](self:Treap[K,V],k:int): K =
#   if self.root == nil: return
#   return self.root.findKth(k).key

import strutils
proc dump*[K,V](self:Treap[K,V],indent:int) : string =
  if self == nil : return ""
  when V is void:
    result = " ".repeat(indent) & "> " & ($self.key) & "\n"
  when V isnot void:
    result = " ".repeat(indent) & "> " & ($self.key) & " -> " & ($self.value) & "(" & ($self.sum)  & ")\n"
  result .add self.left.dump(indent+1)
  result .add self.right.dump(indent+1)
proc dump*[K,V](self:TreapRoot[K,V]) : string = self.root.dump(0)

import times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
if false:
  let n = 1e6.int
  block:
    stopwatch:
      var x = 0
      var A = newTreapRoot[int,int](proc(x,y:int):int = x + y)
      for i in 0..<n: A[randomBit(32)] = i
      # for i in 0..<n:
      #   if randomBit(32) in A : x += 1
      echo x,":",A.len
  block:
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
      var A = newTreapRoot[int]()
      for i in 0..<20:
        A.add randomBit(5)
      # echo A.dump()
      echo toSeq(A.items)
      echo toSeq(A.itemsDesc)
      echo toSeq(A >= 18)
      echo toSeq(A > 18)
      echo toSeq(A <= 18)
      echo toSeq(A < 18)
    # block:
    #   var A = newTreapRoot[int,int](proc(x,y:int):int = x + y)
    #   for i in 0..<20:
    #     A[randomBit(5)] = randomBit(16)
    #   echo A.dump()
    #   echo toSeq(A.items)
