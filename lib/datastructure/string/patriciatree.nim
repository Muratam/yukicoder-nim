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
proc `$`*(self:PatriciaTree):string =
  proc dump(node:PatriciaNode,indent:int = 0):string =
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
      common.countSum += 1
      return
    # まだまだ長さに余力があるが,prefixが違うところに来たのだった. 新しい葉を作って終了
    let differentCharS = S[index].ord - self.offset
    if common.nexts[differentCharS] != nil:
      echo "このメッセージはでないはずだよ"
      doAssert(false)
    common.nexts[differentCharS] = self.charSize.newPatriciaNode(S)
    return

proc len*(self:PatriciaTree):int = self.root.countSum


when isMainModule:
  import strutils
  import algorithm,strutils
  proc `[]`(a:int,i:range[0..63]) : bool = (a and (1 shl i)) != 0
  proc toBoolSeq(a:int): seq[bool] =
    result = newSeq[bool](64)
    for i in 0..<64: result[i] = a[i]
  proc toBinStr(a:int,maxKey:int=64):string =
    result = a.toBoolSeq().reversed().mapIt($it.int).join("")
    result = result[(64-maxKey)..^1]
  import times
  var xorShiftVar* = 88172645463325252.uint64
  xorShiftVar = cast[uint64](cpuTime()) # 初期値を固定しない場合
  proc xorShift() : uint64 =
    xorShiftVar = xorShiftVar xor (xorShiftVar shl 13)
    xorShiftVar = xorShiftVar xor (xorShiftVar shr 7)
    xorShiftVar = xorShiftVar xor (xorShiftVar shl 17)
    return xorShiftVar
  proc random*(maxIndex: int): int =
    cast[int](xorShift() mod maxIndex.uint64)
  proc shuffle*[T](x: var openArray[T]) =
    for i in countdown(x.high, 1):
      swap(x[i], x[random(i)])
  var T = newNumericPatriciaTree()
  for i in 0..<1000:
    T.addMulti random(10000).toBinStr(random(20))
  # T.addMulti "aiueo"
  # T.addMulti "aiaaueo"
  # T.addMulti "aiuedasdo"
  # T.addMulti "aaaiueo"
  # T.addMulti "aiddueoxx"
  echo T
