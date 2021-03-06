# https://yukicoder.me/problems/no/430
import nimprof
type
  PatriciaNode = ref object
    nexts : seq[PatriciaNode]
    count : int # 自身を終端とする文字列の数
    countSum : int # 自身のprefixを持つ文字列の数
    value : string # 念の為全部の値を持っておく.どうせ後で欲しくなるので
  PatriciaTree = ref object
    root : PatriciaNode
    charSize : int
    offset : int
proc newPatriciaNode(charSize:int,value:string):PatriciaNode =
  new(result)
  result.nexts = newSeq[PatriciaNode](charSize)
  result.count = 1
  result.countSum = 1
  result.value = value
proc `$`*(self:PatriciaTree):string =
  proc dump(node:PatriciaNode,indent:int = 0):string =
    if node.countSum == 0 : return ""
    result = ""
    for i in 0..<indent: result.add " "
    result.add node.value & "(" & $node.countSum & ", " & $node.count & ")\n"
    for next in node.nexts:
      if next != nil: result.add next.dump(indent + 1)
  return self.root.dump()
proc newPatriciaTree*(charSize:int,offset:int):PatriciaTree =
  new(result)
  result.root = newPatriciaNode(charSize,"")
  result.root.count = 0
  result.root.countSum = 0
  result.charSize = charSize
  result.offset = offset
proc newLowerCasePatriciaTree*():PatriciaTree = # a~z,26種
  newPatriciaTree('z'.ord - 'a'.ord + 1, 'a'.ord)
proc newUpperCasePatriciaTree*():PatriciaTree = # A~Z,26種
  newPatriciaTree('Z'.ord - 'A'.ord + 1, 'A'.ord)
proc newASCIIPatriciaTree*():PatriciaTree = # ASCII印字可能文字全て,94種
  newPatriciaTree('~'.ord - '!'.ord + 1, '!'.ord)
proc newNumericPatriciaTree*():PatriciaTree = # 0~9,10種
  newPatriciaTree('9'.ord - '0'.ord + 1, '0'.ord)
proc newBytePatriciaTree*():PatriciaTree = # 0~255,256種
  newPatriciaTree(256 , 0)
proc newBinaryPatriciaTree*():PatriciaTree = # 01,2種
  newPatriciaTree(2 , 0)
# 重複を許して追加
proc addMulti*(self:var PatriciaTree,S:string) =
  if S.len == 0: # ""の時
    self.root.count += 1
    self.root.countSum += 1
    return
  var now = self.root
  var index = 0
  while true:
    now.countSum += 1
    # 既に index は該当の場所になっていると仮定
    let s = S[index].ord - self.offset
    # 無かったので追加
    if now.nexts[s] == nil:
      now.nexts[s] = self.charSize.newPatriciaNode(S)
      return
    # now.nexts[s] が存在する
    # どちらがよりふさわしいかを確かめる.
    let minLen = S.len.min(now.nexts[s].value.len)
    while true:
      if index >= minLen: break
      if now.nexts[s].value[index] != S[index]: break
      index += 1
    # 全く同じだった
    if S.len == index and now.nexts[s].value.len == index:
      now.nexts[s].count += 1
      now.nexts[s].countSum += 1
      return
    # 相手の方が短かったので相手はただの通過点であった.
    if now.nexts[s].value.len == index:
      now = now.nexts[s]
      continue
    # 異なるので中間点を作る必要がある
    var common = self.charSize
      .newPatriciaNode(if S.len == index: S else: S[0..<index])
    # 自分の方が短かったので自身を中間点とする
    let differentCharP = now.nexts[s].value[index].ord - self.offset
    let preTree = now.nexts[s]
    now.nexts[s] = common
    common.nexts[differentCharP] = preTree
    common.count = 0
    common.countSum = preTree.countSum + 1
    # そこで終了した
    if S.len == index:
      common.count += 1
      return
    # まだまだ長さに余力があるが,prefixが違うところに来たのだった. 新しい葉を作って終了
    let differentCharS = S[index].ord - self.offset
    if common.nexts[differentCharS] != nil:
      echo "このメッセージはでないはずだよ"
      doAssert(false)
    common.nexts[differentCharS] = self.charSize.newPatriciaNode(S)
    return
# 存在確認
proc `in`*(S:string,self:PatriciaTree) :bool=
  if S.len == 0:
    return self.root.count > 0
  var now = self.root
  var index = 0
  while true:
    let s = S[index].ord - self.offset
    if now.nexts[s] == nil: return false
    if S.len < now.nexts[s].value.len : return false
    while true:
      if index >= now.nexts[s].value.len: break
      if now.nexts[s].value[index] != S[index]: break
      index += 1
    if S.len == index and now.nexts[s].value.len == index:
      return now.nexts[s].count > 0
    if now.nexts[s].value.len == index:
      now = now.nexts[s]
      continue
    return false
# 追加
proc add*(self:var PatriciaTree,S:string) =
  if not (S in self): self.addMulti S
# 構築に時間がかかるので,本当に削除はしない.
# メモリが増えすぎて困る、ということがあれば削除を検討しても良い.
proc delete*(self:var PatriciaTree,S:string) =
  if S.len == 0:
    if self.root.count > 0 :
      self.root.count -= 1
      self.root.countSum -= 1
    return
  if not (S in self): return
  var now = self.root
  var index = 0
  while true:
    now.countSum -= 1
    let s = S[index].ord - self.offset
    if now.nexts[s] == nil: return
    if S.len < now.nexts[s].value.len : return
    while true:
      if index >= now.nexts[s].value.len: break
      if now.nexts[s].value[index] != S[index]: break
      index += 1
    if S.len == index and now.nexts[s].value.len == index:
      if now.nexts[s].count > 0:
        now.nexts[s].count -= 1
        now.nexts[s].countSum -= 1
      return
    if now.nexts[s].value.len == index:
      now = now.nexts[s]
      continue
    return
# 要素数
proc len*(self:PatriciaTree):int = self.root.countSum
proc countWithPrefix*(self:PatriciaTree,S:string):int =
  if S.len == 0: return self.root.countSum
  var index = 0
  var now = self.root
  while true:
    if index >= S.len: return now.countSum
    let s = S[index].ord - self.offset
    if now.nexts[s] == nil:
      # "bcd" に "bc" みたいなノードがきた
      # if index == now.value.len: return now.countSum
      return 0
    if S.len < now.nexts[s].value.len :
      index = now.nexts[s].value.len
      now = now.nexts[s]
      continue
    while true:
      if index >= now.nexts[s].value.len: break
      if now.nexts[s].value[index] != S[index]: break
      index += 1
    now = now.nexts[s]

template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord
let S = stdin.readLine()
let m = scan()
var T = newUpperCasePatriciaTree()
for i in 0..<S.len: T.addMulti S[i..^1]
var ans = 0
m.times:
  let C = stdin.readLine()
  ans += T.countWithPrefix(C)
echo ans
