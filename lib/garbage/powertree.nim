import sequtils
# 要は右からオイラーツアーした平衡(?)二分木.大体Trie木.
# 右は +1 の値を保存
# 左は 2^60 - rank の値を保存
# 途中のノードにも対応する数字が存在するので、普通にTrie木を作るよりもメモリ消費が半分で済む
# 局所性があるのでちょっと速いかも
# でも正直パトリシア木の方が速そう。
type
  PowerTreeNode = ref object
    left,right,parent : PowerTreeNode
    count : int32
    rank : int8
  PowerTree = ref object
    root : PowerTreeNode
    card : int
    multi: bool

const BTN_MAX : int = 60 # 2^60 -1 まで保存可能
proc newPowerTreeNode(parent:PowerTreeNode,rank:int):PowerTreeNode =
  new(result)
  result.parent = parent
  result.rank = rank.int8
proc newPowerTree*(multi:bool):PowerTree =
  new(result)
  result.root = nil.newPowerTreeNode(0)
  result.card = 0
  result.multi = multi
proc add*(self:PowerTree,n:int) =
  var now = self.root
  var nowIndex = 0
  var rank = 0
  while nowIndex != n:
    let left = nowIndex + (1 shl (BTN_MAX - rank))
    rank += 1
    if n >= left :
      nowIndex = left
      if now.left == nil:
        now.left = now.newPowerTreeNode(rank)
      now = now.left
    else:
      nowIndex += 1
      if now.right == nil:
        now.right = now.newPowerTreeNode(rank)
      now = now.right
  if self.multi or now.count == 0:
    now.count += 1
    self.card += 1
  # rank == 60 の時の無効な枝を有効活用したい
  # というかそれ以外でも有向に使えそう
proc len*(self:PowerTree) : int = self.card
proc `in`*(n:int,self:PowerTree) : bool =
  var now = self.root
  var nowIndex = 0
  var rank = 0
  while nowIndex != n:
    let left = nowIndex + (1 shl (BTN_MAX - rank))
    rank += 1
    if n >= left :
      nowIndex = left
      if now.left == nil: return false
      now = now.left
    else:
      nowIndex += 1
      if now.right == nil: return false
      now = now.right
  return true

# 範囲内のものを全て昇順に列挙.
iterator range*(self:PowerTree,x:Slice[int]) : int =
  var now = self.root
  var nowIndex = 0
  while true:
    if nowIndex > x.b : break
    if now.count > 0 and x.a <= nowIndex:
      if self.multi:
        for _ in 0..<now.count: yield nowIndex
      else: yield nowIndex
    proc goNext(lAllow,rAllow:bool) : bool =
      if rAllow and now.right != nil and
          x.a <= nowIndex + (1 shl (BTN_MAX - now.rank)) - 1:
        nowIndex += 1
        now = now.right
        return true
      elif lAllow and now.left != nil :
        nowIndex += (1 shl (BTN_MAX - now.rank))
        now = now.left
        return true
      else: # 戻っていく
        if now.parent == nil: return false
        let isRight = now == now.parent.right
        now = now.parent
        if isRight: nowIndex -= 1
        else: nowIndex -= (1 shl (BTN_MAX - now.rank))
        return goNext(isRight,false)
    if not goNext(true,true): break
# 全ての要素を昇順に列挙.
iterator items*(self:PowerTree) : int =
  for x in self.range(0..int.high): yield x
# 最小値
proc min*(self:PowerTree,x:Slice[int] = 0..int.high) : int =
  for x in self.range(x): return x
  return -1
# 全ての要素を逆順に列挙
iterator revitems*(self:PowerTree) : int =
  var now = self.root
  var nowIndex = 0
  while true:
    if now.count > 0:
      if self.multi:
        for _ in 0..<now.count: yield nowIndex
      else: yield nowIndex
    proc goNext(lAllow,rAllow:bool) : bool =
      if rAllow and now.right != nil:
        nowIndex += 1
        now = now.right
        return true
      elif lAllow and now.left != nil:
        nowIndex += (1 shl (BTN_MAX - now.rank))
        now = now.left
        return true
      else: # 戻っていく
        if now.parent == nil: return false
        let isRight = now == now.parent.right
        now = now.parent
        if isRight: nowIndex -= 1
        else: nowIndex -= (1 shl (BTN_MAX - now.rank))
        return goNext(isRight,false)
    if not goNext(true,true): break





var T = newPowerTree(false)
T.add(100)
T.add(200)
T.add(300)
echo 100 in T
echo 200 in T
echo 300 in T
echo 400 in T == false
echo T.min() == 100
for x in T.range(150..<200):
  echo x
