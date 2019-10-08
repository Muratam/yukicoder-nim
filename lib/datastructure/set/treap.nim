import nimprof
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
  # count*:int32 # 実は count は不要？
  # sum*:int # とりあえず総和のモノイド
type Treap*[T] = ref object
  root*:TreapNode[T]
# proc len[T](self:TreapNode[T]) : int32 =
#   if self == nil: 0 else: self.count
# proc len*[T](self:Treap[T]) : int =
#   if self.root = nil : 0 else: self.root.len
# はい
proc newTreapNode*[T](key:T):TreapNode[T] =
  new(result)
  result.key = key
  result.priority = randomBit(30).int32
  # result.count = 1
  # result.sum = value.T # とりあえずね
# モノイド操作をしたければ書く
proc update[T](self:TreapNode[T]) : TreapNode[T] {.discardable.}=
  # self.count = self.left.len + self.right.len + 1
  # self.sum =
  return self
# 必ず ∀[left] < ∀[right] の時に呼ばれるという仮定を置いている
proc merge*[T](left,right:TreapNode[T]) : TreapNode[T] =
  if left == nil: return right
  if right == nil : return left
  # 優先度が高い方を根にする
  if left.priority > right.priority:
    left.right = left.right.merge(right)
    return left.update()
  else:
    right.left = left.merge(right.left)
    return right.update()
# 再帰的に切るだけ. (子は必ず優先度が低いので)
proc split*[T](self:TreapNode[T],key:T): tuple[l,r:TreapNode[T]] =
  if self == nil: return (nil,nil)
  # if self.left == nil
  #   if self.right == nil:
  #     if key < self.key : return (nil,self)
  #     return (self,nil)
  #   if key < self.key : return (nil,self)
  if key < self.key:
    let s = self.left.split(key)
    self.left = s.r
    return (s.l,self.update())
  else:
    let s = self.right.split(key)
    self.right = s.l
    return (self.update(),s.r)
# left < key <= right になる
proc add*[T](self:var TreapNode[T],key: T)=
  let s = self.split(key)
  self = s.l.merge(newTreapNode(key).merge(s.r))
# 自分にさようなら
proc erase*[T](self:var TreapNode[T],key:T) =
  if self.key == key:
    self = self.merge(self.left,self.right)
  elif key < self.key:
    if self.left == nil : return
    self.left.erase(key)
  else:
    if self.right == nil : return
    self.right.erase(key)
proc newTreap*[T]():Treap[T] = new(result)
proc add*[T](self:var Treap[T],key:T) =
  if self.root == nil :self.root = newTreapNode(key)
  else: self.root.add(key)
proc erase*[T](self:var Treap[T],key:T) =
  if self.root == nil : return
  self.root.erase(key)

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
#  200ms: HashSet[int]() / Table[int,int]()
# 1000ms: std::set[int]()
# 2800ms: Treap[int]()
stopwatch:
  var A = newTreap[int]()
  for i in 0..<1e6.int: A.add i
  echo A.root.priority
  echo A.root.key

# stopwatch: # 400ms くらい？
#   var A = newTreapNode(100.0)
#   for i in 0..<1e6.int:
#     A[i] = i.float
#   echo A.len
# stopwatch: # 400ms くらい？
#   for i in 0..<1e6.int:
#     A.erase(i)
#   echo A.len
