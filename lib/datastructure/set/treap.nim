# https://www.slideshare.net/iwiwi/2-12188757
# カスタムの比較関数や,カスタムの木の操作をしたい場合はこちら.
# 区間に対する操作が

# multi-add で実装.(add だけを許可したければチェックしてからaddすればよいので)
# セグツリみたいなことをする？
# k番目のやつも書けると嬉しいね！
# newするの遅いし先にやる感じ？
# kthByOrder / orderByKth も欲しい

import "../../mathlib/random"
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
# Treapの根を指すラッパーを作成することで、いろいろな操作がしやすい.
type TreapRoot*[K,V] = ref object
  root*:Treap[K,V]
  apply*:SemiGroup[V]
proc newTreapRoot*[K,V](apply:SemiGroup[V]):TreapRoot[K,V] =
  result = TreapRoot[K,V](apply:apply)
proc `[]=`*[K,V](self:var TreapRoot[K,V],key:K,value:V) =
  self.root.add(newTreap(self.apply,key,value))
proc excl*[K,V](self:var TreapRoot[K,V],key:K) =
  if self.root == nil : return
  self.root.excl(key)
proc len*[K,V](self:TreapRoot[K,V]) : int =
  if self.root == nil : 0 else: self.root.len

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
  echo A.len
  # for i in 0..<1e6.int: A[randomBit(32)] = i
  # echo A.len
