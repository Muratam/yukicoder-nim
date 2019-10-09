# https://www.slideshare.net/iwiwi/2-12188757
# Treap : 区間木 + 動的木, 定数倍は重い.
# 0. key: min,max,iter,kth,add,erase,find
#    value: RMQ(1点更新/区間モノイド)
# 1. key には int以外のカスタムの比較関数も取れる
# 2. 素な区間に対するモノイドができる.
# 3. 区間の Split / Merge ができる.
# 4. カスタムの木の操作をしたい場合, 書きやすい.

import "../../mathlib/random"
import sequtils
# 余分な葉が無いので半群(モノイドに比べて単位元が不要)でよい
type SemiGroup*[K] = proc(x,y:K):K
type Treap*[K,V] = ref object
  key*: K
  priority*: int32
  left*,right*: Treap[K,V] # left: [-∞..key) / right: [key,∞)
  count*:int32 # k番目の最小を取るために必要.
  value*,sum*: V
  apply*:SemiGroup[V] # 全員が持つのはちょっと無駄かも(あまり変わらないが)
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
proc update[K,V](self:Treap[K,V]) : Treap[K,V] {.discardable.}=
  self.count = self.left.len + 1 + self.right.len
  self.sum = self.value
  if self.left != nil: self.sum = self.apply(self.left.sum,self.sum)
  if self.right != nil: self.sum = self.apply(self.sum,self.right.sum)
  return self
proc merge*[K,V](left,right:Treap[K,V]) : Treap[K,V] =
  # 必ず ∀[left] < ∀[right] の時に呼ばれるという仮定を置いている
  if left == nil: return right
  if right == nil : return left
  # 優先度が高い方を根にする
  if left.priority > right.priority:
    left.right = left.right.merge(right)
    return left.update()
  else:
    right.left = left.merge(right.left)
    return right.update()
proc split*[K,V](self:Treap[K,V],key:K): tuple[l,r:Treap[K,V]] =
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
proc excl*[K,V](self:var Treap[K,V],key:K) =
  # 自分にさようなら
  if self.key == key:
    self = self.left.merge(self.right)
    return
  elif key < self.key:
    if self.left == nil : return
    self.left.excl(key)
  else:
    if self.right == nil : return
    self.right.excl(key)
  self.update()
proc findByKey*[K,V](self:Treap[K,V],key:K) : Treap[K,V]=
  if self.key == key: return self
  if key < self.key:
    if self.left == nil : return nil
    return self.left.findByKey(key)
  else:
    if self.right == nil: return nil
    return self.right.findByKey(key)
proc findMin*[K,V](self:Treap[K,V]) : Treap[K,V] =
  if self.left == nil: return self
  return self.left.findMin()
proc findMax*[K,V](self:Treap[K,V]) : Treap[K,V] =
  if self.right == nil: return self
  return self.right.findMax()
# 要素を昇順に列挙
iterator items*[K,V](self:Treap[K,V]) : Treap[K,V] =
  var treaps = newSeq[Treap[K,V]]()
  treaps.add self
  while treaps.len > 0:
    echo treaps.mapIt($it.key)
    if treaps[^1].left == nil:
      let now = treaps.pop()
      yield now
      if now.right != nil:
        treaps.add now.right
    else:
      treaps.add treaps[^1].left

# Treapの根を指すラッパーを作成することで、いろいろな操作がしやすい.
# 特に,自身は必ず nil ではないので操作がやりやすい.
type TreapRoot*[K,V] = ref object
  root*:Treap[K,V]
  apply*:SemiGroup[V]
  multiAdd*:bool
proc newTreapRootWith[K,V](self:TreapRoot[K,V],treap:Treap[K,V]):TreapRoot[K,V] =
  result = TreapRoot[K,V](
    apply:self.apply,
    multiAdd:self.multiAdd,
    root:treap
  )
proc newTreapRoot*[K,V](apply:SemiGroup[V],multiAdd:bool = true):TreapRoot[K,V] =
  result = TreapRoot[K,V](apply:apply,multiAdd:multiAdd)
proc `[]=`*[K,V](self:var TreapRoot[K,V],key:K,value:V) =
  # 無ければ追加.とすることで擬似的に multiadd / add を切り替えられる(multiじゃないときはコストだが)
  if not self.multiAdd and key in self: return
  self.root.add(newTreap(self.apply,key,value))
proc excl*[K,V](self:var TreapRoot[K,V],key:K) =
  if self.root == nil : return
  self.root.excl(key)
proc len*[K,V](self:TreapRoot[K,V]) : int =
  if self.root == nil : 0 else: self.root.len
proc findByKey*[K,V](self:TreapRoot[K,V],key:K):TreapRoot[K,V]=
  if self.root == nil: return nil
  return self.newTreapRootWith(self.root.findByKey(key))
proc contains*[K,V](self:TreapRoot[K,V],key:K):bool=
  if self.root == nil : return false
  return self.root.findByKey(key) != nil
proc findMinKey*[K,V](self:TreapRoot[K,V]):K=
  assert self.root != nil
  return self.root.findMin().key
proc findMaxKey*[K,V](self:TreapRoot[K,V]):K=
  assert self.root != nil
  return self.root.findMax().key


import strutils
proc dump*[K,V](self:Treap[K,V],indent:int) : string =
  if self == nil : return ""
  result = " ".repeat(indent) & "|" & ($self.key) & " -> " & ($self.value) & "(" & ($self.sum)  & ")\n"
  result .add self.left.dump(indent+1)
  result .add self.right.dump(indent+1)
proc dump*[K,V](self:TreapRoot[K,V]) : string = self.root.dump(0)

import times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
stopwatch:
  var A = newTreapRoot[int,int](proc(x,y:int):int = x + y)
  A[0] = 10
  A[50] = 10
  A[100] = 20
  A[0] = 10
  A[50] = 10
  A[100] = 20
  A[100] = 20
  A[100] = 20
  A[100] = 20
  echo A.dump()
  for x in A.root:
    echo x.key,":",x.value
  # echo A.dump()
  # echo A.len
  # echo 100 in A
  # A.excl 100
  # A.excl 100
  # A.excl 100
  # A.excl 100
  # A.excl 100
  # A.excl 100
  # echo 100 in A
  # echo A.dump()
  # echo A.len
  # for i in 0..<1e6.int: A[randomBit(32)] = i
  # echo A.len
