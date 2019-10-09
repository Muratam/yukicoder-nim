# https://www.slideshare.net/iwiwi/2-12188757
# LightTreap : 区間木 + 動的木, 定数倍は重い.
# Nimの std::set がよくわからないバグを吐くので軽量のTreapが必要.
# min,max,iter,kth,add,erase,find ができる.

# 動的木
# 赤黒木 : 基本.最悪でもO(logN)
# AVL木 : 平衡. 構築が遅い分探索が速い
# スプレー木 : キャッシュ. 最近アクセスした要素に関して速い.
# Treap : 乱択. 実装が軽い
# RBST : ↑ の priorityが不要版
# Heap : 一番上が最大であることしか保証しない

import "../../mathlib/random"
import sequtils
type LightTreap = ref object
  priority*: int32
  left*,right*: LightTreap # left: [-∞..key) / right: [key,∞)
  count*:int # k番目の最小を取るために必要...?.
proc newLightTreap*():LightTreap =
  result = LightTreap(
    priority:randomBit(30).int32,
    count:1,
  )
proc len(self:LightTreap) : int32 =
  if self == nil: 0 else: self.count
proc update(self:LightTreap) : LightTreap {.discardable.}=
  self.count = self.left.len + 1 + self.right.len
  return self
proc merge*(left,right:LightTreap) : LightTreap =
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
proc split*(self:LightTreap,key:K): tuple[l,r:LightTreap] =
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
proc add*(self:var LightTreap,item: LightTreap) =
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
proc excl*(self:var LightTreap,key:K) =
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
proc findByKey*(self:LightTreap,key:K) : LightTreap=
  if self.key == key: return self
  if key < self.key:
    if self.left == nil : return nil
    return self.left.findByKey(key)
  else:
    if self.right == nil: return nil
    return self.right.findByKey(key)
proc findMin*(self:LightTreap) : LightTreap =
  if self.left == nil: return self
  return self.left.findMin()
proc findMax*(self:LightTreap) : LightTreap =
  if self.right == nil: return self
  return self.right.findMax()
# 要素を昇順に列挙
iterator items*(self:LightTreap) : LightTreap =
  var treaps = newSeq[LightTreap]()
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

# LightTreapの根を指すラッパーを作成することで、いろいろな操作がしやすい.
# 特に,自身は必ず nil ではないので操作がやりやすい.
type LightTreapRoot* = ref object
  root*:LightTreap
  apply*:SemiGroup[V]
  multiAdd*:bool
proc newLightTreapRootWith(self:LightTreapRoot,treap:LightTreap):LightTreapRoot =
  result = LightTreapRoot(
    apply:self.apply,
    multiAdd:self.multiAdd,
    root:treap
  )
proc newLightTreapRoot*(apply:SemiGroup[V],multiAdd:bool = true):LightTreapRoot =
  result = LightTreapRoot(apply:apply,multiAdd:multiAdd)
proc `[]=`*(self:var LightTreapRoot,key:K,value:V) =
  # 無ければ追加.とすることで擬似的に multiadd / add を切り替えられる(multiじゃないときはコストだが)
  if not self.multiAdd and key in self: return
  self.root.add(newLightTreap(self.apply,key,value))
proc excl*(self:var LightTreapRoot,key:K) =
  if self.root == nil : return
  self.root.excl(key)
proc len*(self:LightTreapRoot) : int =
  if self.root == nil : 0 else: self.root.len
proc findByKey*(self:LightTreapRoot,key:K):LightTreapRoot=
  if self.root == nil: return nil
  return self.newLightTreapRootWith(self.root.findByKey(key))
proc contains*(self:LightTreapRoot,key:K):bool=
  if self.root == nil : return false
  return self.root.findByKey(key) != nil
proc findMinKey*(self:LightTreapRoot):K=
  assert self.root != nil
  return self.root.findMin().key
proc findMaxKey*(self:LightTreapRoot):K=
  assert self.root != nil
  return self.root.findMax().key


import strutils
proc dump*(self:LightTreap,indent:int) : string =
  if self == nil : return ""
  result = " ".repeat(indent) & "|" & ($self.key) & " -> " & ($self.value) & "(" & ($self.sum)  & ")\n"
  result .add self.left.dump(indent+1)
  result .add self.right.dump(indent+1)
proc dump*(self:LightTreapRoot) : string = self.root.dump(0)

import times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
stopwatch:
  var A = newLightTreapRoot[int,int](proc(x,y:int):int = x + y)
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
