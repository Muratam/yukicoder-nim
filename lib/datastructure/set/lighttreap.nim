# https://www.slideshare.net/iwiwi/2-12188757
# LightTreap: std::set(+kth)を実現. 速度重視.
# min,max,iter,kth,add,erase,find ができる.
# セグツリ機能を付けたければ Treap.nim で!!
import "../../mathlib/random"
import sequtils
type LightTreap[T] = ref object
  key: T
  priority*: int32
  left*,right*: LightTreap[T] # left: [-∞..key) / right: [key,∞)
  count*:int # k番目の最小を取るために必要.
proc newLightTreap*[T](key:T):LightTreap[T] =
  result = LightTreap[T](
    key: key,
    priority:randomBit(30).int32,
    count:1,
  )
proc update[T](self:LightTreap[T]) : LightTreap[T] {.discardable.}=
  self.count = self.left.len + 1 + self.right.len
  return self
proc len*[T](self:LightTreap[T]) : int32 =
  if self == nil: 0 else: self.count
proc merge*[T](left,right:LightTreap[T]) : LightTreap[T] =
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
proc split*[T](self:LightTreap[T],key:T): tuple[l,r:LightTreap[T]] =
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
proc add*[T](self:var LightTreap[T],item: LightTreap[T]) =
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
proc excl*[T](self:var LightTreap[T],key:T) =
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
proc findByKey*[T](self:LightTreap[T],key:T) : LightTreap[T]=
  if self.key == key: return self
  if key < self.key:
    if self.left == nil : return nil
    return self.left.findByKey(key)
  else:
    if self.right == nil: return nil
    return self.right.findByKey(key)
proc findMin*[T](self:LightTreap[T]) : LightTreap[T] =
  if self.left == nil: return self
  return self.left.findMin()
proc findMax*[T](self:LightTreap[T]) : LightTreap[T] =
  if self.right == nil: return self
  return self.right.findMax()
# 要素を昇順に列挙
iterator items*[T](self:LightTreap[T]) : LightTreap[T] =
  var treaps = newSeq[LightTreap[T]]()
  # treaps.add self
  # while treaps.len > 0:
  #   echo treaps.mapIt($it.key)
  #   if treaps[^1].left == nil:
  #     let now = treaps.pop()
  #     yield now
  #     if now.right != nil:
  #       treaps.add now.right
  #   else:
  #     treaps.add treaps[^1].left

# LightTreapの根を指すラッパーを作成することで、いろいろな操作がしやすい.
# 特に,自身は必ず nil ではないので操作がやりやすい.
type LightTreapRoot*[T] = ref object
  root*:LightTreap[T]
  multiAdd*:bool
proc newLightTreapRootWith[T](self:LightTreapRoot[T],treap:LightTreap[T]):LightTreapRoot[T] =
  result = LightTreapRoot(
    multiAdd:self.multiAdd,
    root:treap
  )
proc newLightTreapRoot*[T](multiAdd:bool = true):LightTreapRoot[T] =
  result = LightTreapRoot[T](multiAdd:multiAdd)
proc contains*[T](self:LightTreapRoot,key:T):bool=
  if self.root == nil : return false
  return self.root.findByKey(key) != nil
proc add*[T](self:var LightTreapRoot[T],key:T) =
  # 無ければ追加.とすることで擬似的に multiadd / add を切り替えられる(multiじゃないときはコストだが)
  if not self.multiAdd and key in self: return
  self.root.add(newLightTreap(key))
proc excl*[T](self:var LightTreapRoot[T],key:T) =
  if self.root == nil : return
  self.root.excl(key)
proc len*[T](self:LightTreapRoot[T]) : int =
  if self.root == nil : 0 else: self.root.len
proc findByKey*[T](self:LightTreapRoot[T],key:T):LightTreapRoot[T]=
  if self.root == nil: return nil
  return self.newLightTreapRootWith(self.root.findByKey(key))
proc findMinKey*[T](self:LightTreapRoot[T]):T=
  assert self.root != nil
  return self.root.findMin().key
proc findMaxKey*[T](self:LightTreapRoot[T]):T=
  assert self.root != nil
  return self.root.findMax().key

import strutils
proc dump*[T](self:LightTreap[T],indent:int) : string =
  if self == nil : return ""
  if self.left == nil and self.right == nil:
    result = " ".repeat(indent) & ">" & ($self.key) & "\n"
  else:
    result = " ".repeat(indent) & ($self.key) & "\n"
  result .add self.left.dump(indent+1)
  result .add self.right.dump(indent+1)
proc dump*[T](self:LightTreapRoot[T]) : string = self.root.dump(0)

import times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
stopwatch:
  var A = newLightTreapRoot[int]()
  for i in 0..<1e6.int:
    A.add randomBit(30)

  # for x in A.root:
  #   echo x.key,":",x.value
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
