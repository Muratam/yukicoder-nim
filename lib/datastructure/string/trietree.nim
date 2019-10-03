# トライ木 (prefix-tree)
# 追加・prefix探索が O(|S|)
# 小さい文字列を大量に扱う場合に適当
# 長い文字列ではパトリシア木(Radix-Tree)を使う
import sequtils
type
  TrieNode = ref object
    nexts : seq[TrieNode]
    nextChars : seq[int]
    hasTerminal : bool
    character : char
  TrieTree = ref object
    root : TrieNode
    charSize : int
    offset : int
    card : int
proc newTrieNode(charSize:int,character:char):TrieNode =
  new(result)
  result.nexts = newSeq[TrieNode](charSize)
  result.nextChars = @[]
  result.hasTerminal = false
  result.character = character
proc newTrieTree*(charSize:int,offset:int):TrieTree =
  new(result)
  result.root = newTrieNode(charSize,'\0')
  result.charSize = charSize
  result.offset = offset
  result.card = 0
proc newLowerCaseTrieTree*():TrieTree = # a~z,26種
  newTrieTree('z'.ord - 'a'.ord , 'a'.ord)
proc newUpperCaseTrieTree*():TrieTree = # A~Z,26種
  newTrieTree('Z'.ord - 'A'.ord , 'A'.ord)
proc newASCIITrieTree*():TrieTree = # ASCII印字可能文字全て,94種
  newTrieTree('~'.ord - '!'.ord, '!'.ord)
proc newNumericTrieTree*():TrieTree = # 0~9,10種
  newTrieTree('9'.ord - '0'.ord , '0'.ord)
proc newByteTrieTree*():TrieTree = # 0~255,256種
  newTrieTree(256 , 0)
proc newBinaryTrieTree*():TrieTree = # 01,2種
  newTrieTree(2 , 0)
proc add*(self:TrieTree,S:string) =
  var now = self.root
  for sRaw in S:
    let s = sRaw.ord - self.offset
    if now.nexts[s] == nil:
      now.nexts[s] = newTrieNode(self.charSize,sRaw)
      now.nextChars.add s
    now = now.nexts[s]
  if now.hasTerminal: return
  now.hasTerminal = true
  self.card += 1
# proc del(self:TrieTree,S:string) =
#   var now = self.root
#   for sRaw in S:
#     let s = sRaw.ord - self.offset
#     if now.nexts[s] == nil:
#       return
#     now = now.nexts[s]
#   if not now.hasTerminal: return
#   now.hasTerminal = false
#   self.card -= 1
#   if now.nextChars.len == 0:
proc findNode(self:TrieTree,S:string) : TrieNode =
  var now = self.root
  for i in 0..<S.len:
    let s = S[i].ord - self.offset
    now = now.nexts[s]
    if now == nil:
      return nil
  return now
iterator items*(now:TrieNode): string =
  var now = now
  if now.hasTerminal: yield ""
  var C = newSeq[char]()
  var stack = newSeq[TrieNode]()
  for c in now.nextChars:
    stack.add now.nexts[c]
  echo now.nextChars
  while stack.len > 0:
    now = stack.pop()
    C.add now.character
    if now.hasTerminal:
      yield cast[string](C)
    for c in now.nextChars:
      stack.add now.nexts[c]
    if now.nextChars.len == 0:
      discard stack.pop()

iterator findPrefix*(self:TrieTree,S:string) : string =
  let node = self.findNode(S)
  if node != nil :
    for x in node:
      yield S & x
proc len*(self:TrieTree):int = self.card


when isMainModule:
  import strutils
  var T = newNumericTrieTree()
  T .add "22222"
  T .add "12345"
  T .add "12333".repeat(2)
  T .add "12334".repeat(2)
  T .add "12335".repeat(2)
  T .add ""
  T .add "22222"
  echo T.len
  for s in T.findPrefix("123"):
    echo s[0..<5]
