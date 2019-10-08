# import nimprof
# https://www.slideshare.net/iwiwi/2-12188757
# 普通は std::set でよい.
# カスタムの比較関数や,カスタムの木の操作をしたい場合はこちら.
# multi-add で実装.(add だけを許可したければチェックしてからaddすればよいので)
# セグツリみたいなことをする？
# k番目のやつも書けると嬉しいね！
# newするの遅いし先にやる感じ？

import "../../mathlib/random"
type TreapNode*[T] = ref object
  key*: T
  priority*: int32
  left*,right*: TreapNode[T] # left: [-∞..key) / right: [key,∞)
  count*:int32 # k番目の最小を取るために必要.
  # sum*:int # とりあえず総和のモノイド
type Treap*[T] = ref object
  root*:TreapNode[T]
# はい
proc newTreapNode*[T](key:T):TreapNode[T] =
  result = TreapNode[T](
    key:key,
    priority:randomBit(30).int32,
    count:1
  )
  # result.sum = unit # とりあえずね
# モノイド操作をしたければ書く
proc len[T](self:TreapNode[T]) : int32 =
  if self == nil: 0 else: self.count
proc update[T](self:TreapNode[T]) : TreapNode[T] {.discardable.}=
  self.count = self.left.len + self.right.len + 1
  # self.sum =
  return self
proc merge*[T](left,right:TreapNode[T]) : TreapNode[T] =
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
proc split*[T](self:TreapNode[T],key:T): tuple[l,r:TreapNode[T]] =
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
proc add*[T](self:var TreapNode[T],item: TreapNode[T]) =
  if self == nil: self = item
  elif item.priority > self.priority:
    let s = self.split(item.key)
    item.left = s.l
    item.right = s.r
    self = item
  elif item.key < self.key:
    self.left.add(item)
  else:
    self.right.add(item)
  # left < key <= right になる
proc erase*[T](self:var TreapNode[T],key:T) =
  # 自分にさようなら
  if self.key == key:
    self = self.left.merge(self.right)
  elif key < self.key:
    if self.left == nil : return
    self.left.erase(key)
  else:
    if self.right == nil : return
    self.right.erase(key)
proc newTreap*[T]():Treap[T] = new(result)
proc add*[T](self:var Treap[T],key:T) =
  self.root.add(newTreapNode(key))
proc erase*[T](self:var Treap[T],key:T) =
  if self.root == nil : return
  self.root.erase(key)
proc len*[T](self:Treap[T]) : int =
  if self.root == nil : 0 else: self.root.len

import strutils
proc dump*[T](self:TreapNode[T],indent:int) : string =
  if self == nil : return ""
  result = " ".repeat(indent) & ":" & ($self.key) & "\n"
  result .add self.left.dump(indent+1)
  result .add self.right.dump(indent+1)
proc dump*[T](self:Treap[T]) : string = self.root.dump(0)

import times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")

# データ数 1e6,ランダムケース に対して
#   20ms: seq[int](add)
#  200ms: HashSet[int]() / Table[int,int]() / Treap
#  320ms: Treap[int]()
# 1000ms: std::set[int]()
# 2000ms: Treap[int]
stopwatch:
  var A = newTreap[int]()
  for i in 0..<1e6.int: A.add randomBit(32)
  echo A.root.priority
  echo A.root.key
  echo A.len
# stopwatch:
#   for i in 10..<1e6.int: A.erase i
#   echo A.len

# stopwatch: # 400ms くらい？
#   var A = newTreapNode(100.0)
#   for i in 0..<1e6.int:
#     A[i] = i.float
#   echo A.len
# stopwatch: # 400ms くらい？
#   for i in 0..<1e6.int:
#     A.erase(i)
#   echo A.len
