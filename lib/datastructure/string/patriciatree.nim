# トライ木 (prefix-tree)
# 追加・prefix探索・が O(|S|)
import sequtils
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
proc newPatriciaTree*(charSize:int,offset:int):PatriciaTree =
  new(result)
  result.root = newPatriciaNode(charSize,"")
  result.root.count = 0
  result.root.countSum = 0
  result.charSize = charSize
  result.offset = offset
proc newLowerCasePatriciaTree*():PatriciaTree = # a~z,26種
  newPatriciaTree('z'.ord - 'a'.ord , 'a'.ord)
proc newUpperCasePatriciaTree*():PatriciaTree = # A~Z,26種
  newPatriciaTree('Z'.ord - 'A'.ord , 'A'.ord)
proc newASCIIPatriciaTree*():PatriciaTree = # ASCII印字可能文字全て,94種
  newPatriciaTree('~'.ord - '!'.ord, '!'.ord)
proc newNumericPatriciaTree*():PatriciaTree = # 0~9,10種
  newPatriciaTree('9'.ord - '0'.ord , '0'.ord)
proc newBytePatriciaTree*():PatriciaTree = # 0~255,256種
  newPatriciaTree(256 , 0)
proc newBinaryPatriciaTree*():PatriciaTree = # 01,2種
  newPatriciaTree(2 , 0)
proc addMulti*(self:PatriciaTree,S:string) =
  if S.len == 0: # ""の時
    self.root.count += 1
    self.root.countSum += 1
    return
  var now = self.root
  var index = 0
  while true:
    now.countSum += 1
    let s = S[index].ord - self.offset
     # 無かったので追加
    if now.nexts[s] == nil:
      now.nexts[s] = self.charSize.newPatriciaNode(S)
      return
    let minLen = S.len.min(now.nexts[s].value.len)
    while true:
      if index >= minLen: break
      if now.nexts[s].value[index] != S[index]: break
      index += 1
    # 自分は短かった
    if S.len == index:
      # 全く同じだったので何もしなくて良い
      if S.len == now.nexts[s].value.len:
        now.nexts[s].count += 1
        now.nexts[s].countSum += 1
        return
      # 相手の方が長かったので自身を中間点とする
      var common = self.charSize.newPatriciaNode(S)
      let preTree = now.nexts[s]
      let differentCharP = now.nexts[s].value[index].ord - self.offset
      now.nexts[s] = common
      common.nexts[differentCharP] = preTree
      common.count = 1
      common.countSum = preTree.countSum + 2
      return
    # 次へ
    let differentCharS = S[index].ord - self.offset
    if now.nexts[s].nexts[differentCharS] != nil:
      now.nexts[s].countSum += 1
      now = now.nexts[s].nexts[differentCharS] # WARN
      continue
    # ちょうどそれがprefix だった
    if now.nexts[s].value.len == index:
      now = now.nexts[s]
      continue
    # 中間点を作成
    let commonPrefix = S[0..<index]
    var common = self.charSize.newPatriciaNode(commonPrefix)
    let preTree = now.nexts[s]
    let differentCharP = now.nexts[s].value[index].ord - self.offset
    now.nexts[s] = common
    common.nexts[differentCharS] = self.charSize.newPatriciaNode(S)
    common.nexts[differentCharP] = preTree
    common.count = 0
    common.countSum = preTree.countSum + 1
    return
proc len*(self:PatriciaTree):int = self.root.countSum
proc `$`*(self:PatriciaTree):string =
  proc dump(node:PatriciaNode,indent:int = 0):string =
    result = ""
    for i in 0..<indent: result.add " "
    result.add node.value & "(" & $node.countSum & ", " & $node.count & ")\n"
    for next in node.nexts:
      if next != nil: result.add next.dump(indent + 1)
  return self.root.dump()


when isMainModule:
  import strutils
  var T = newNumericPatriciaTree()
  T.addMulti "22222"
  echo T
  T.addMulti "12345"
  echo T
  T.addMulti "22333"
  echo T
  T.addMulti "22333444"
  echo T
  T.addMulti "22333444"
  echo T
  T.addMulti ""
  echo T
  T.addMulti "123456789"
  echo T
  T.addMulti "1234"
  echo T
  T.addMulti "22334"
  echo T
