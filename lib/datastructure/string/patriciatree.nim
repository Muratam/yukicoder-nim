
import critbits
# 標準ライブラリにパトリシア木があるのでそれをモノイドに拡張したもの
include "system/inclrtl"
type
  NodeObj[T] = object # {.acyclic.}
    byte: int
    otherBits: char
    case isLeaf: bool
    of false: child: array[0..1, ref NodeObj[T]]
    of true:
      key: string
      val: T
  Node[T] = ref NodeObj[T]
  CritBitTree*[T] = object
    root: Node[T]
    count: int

proc len*[T](c: CritBitTree[T]): int =  c.count
proc rawGet[T](c: CritBitTree[T], key: string): Node[T] =
  var it = c.root
  while it != nil:
    if not it.isLeaf:
      let ch = if it.byte < key.len: key[it.byte] else: '\0'
      let dir = (1 + (ch.ord or it.otherBits.ord)) shr 8
      it = it.child[dir]
    else:
      return if it.key == key: it else: nil
proc contains*[T](c: CritBitTree[T], key: string): bool {.inline.} = rawGet(c, key) != nil
proc rawInsert[T](c: var CritBitTree[T], key: string): Node[T] =
  if c.root == nil:
    c.root = Node[T](isleaf: true, key: key)
    result = c.root
  else:
    var it = c.root
    while not it.isLeaf:
      let ch = if it.byte < key.len: key[it.byte] else: '\0'
      let dir = (1 + (ch.ord or it.otherBits.ord)) shr 8
      it = it.child[dir]
    var newOtherBits = 0
    var newByte = 0
    block blockX:
      while newByte < key.len:
        let ch = if newByte < it.key.len: it.key[newByte] else: '\0'
        if ch != key[newByte]:
          newOtherBits = ch.ord xor key[newByte].ord
          break blockX
        inc newByte
      if newByte < it.key.len:
        newOtherBits = it.key[newByte].ord
      else:
        return it
    while (newOtherBits and (newOtherBits-1)) != 0:
      newOtherBits = newOtherBits and (newOtherBits-1)
    newOtherBits = newOtherBits xor 255
    let ch = if newByte < it.key.len: it.key[newByte] else: '\0'
    let dir = (1 + (ord(ch) or newOtherBits)) shr 8
    var inner: Node[T]
    new inner
    result = Node[T](isLeaf: true, key: key)
    inner.otherBits = chr(newOtherBits)
    inner.byte = newByte
    inner.child[1 - dir] = result

    var wherep = addr(c.root)
    while true:
      var p = wherep[]
      if p.isLeaf: break
      if p.byte > newByte: break
      if p.byte == newByte and p.otherBits.ord > newOtherBits: break
      let ch = if p.byte < key.len: key[p.byte] else: '\0'
      let dir = (1 + (ch.ord or p.otherBits.ord)) shr 8
      wherep = addr(p.child[dir])
    inner.child[dir] = wherep[]
    wherep[] = inner
  inc c.count
proc exclImpl[T](c: var CritBitTree[T], key: string): int =
  var p = c.root
  var wherep = addr(c.root)
  var whereq: ptr Node[T] = nil
  if p == nil: return c.count
  var dir = 0
  var q: Node[T]
  while not p.isLeaf:
    whereq = wherep
    q = p
    let ch = if p.byte < key.len: key[p.byte] else: '\0'
    dir = (1 + (ch.ord or p.otherBits.ord)) shr 8
    wherep = addr(p.child[dir])
    p = wherep[]
  if p.key == key:
    if whereq == nil:
      c.root = nil
    else:
      whereq[] = q.child[1 - dir]
    dec c.count
  return c.count
proc excl*[T](c: var CritBitTree[T], key: string) = discard exclImpl(c, key)
proc `[]=`*[T](c: var CritBitTree[T], key: string, val: T) = rawInsert(c, key).val = val
proc `[]`*[T](c: CritBitTree[T], key: string): T {.inline.} = rawGet(c, key).val
proc `[]`*[T](c: var CritBitTree[T], key: string): var T {.inline.} = rawGet(c, key).val
iterator leaves[T](n: Node[T]): Node[T] =
  if n != nil:
    var stack = @[n]
    while stack.len > 0:
      var it = stack.pop
      while not it.isLeaf:
        stack.add(it.child[1])
        it = it.child[0]
        assert(it != nil)
      yield it
iterator keys*[T](c: CritBitTree[T]): string =
  for x in leaves(c.root): yield x.key
iterator values*[T](c: CritBitTree[T]): T =
  for x in leaves(c.root): yield x.val
proc allprefixedAux[T](c: CritBitTree[T], key: string, longestMatch: bool): Node[T] =
  var p = c.root
  var top = p
  if p == nil: return nil
  while not p.isLeaf:
    var q = p
    let ch = if p.byte < key.len: key[p.byte] else: '\0'
    let dir = (1 + (ch.ord or p.otherBits.ord)) shr 8
    p = p.child[dir]
    if q.byte < key.len: top = p
  if not longestMatch:
    for i in 0 ..< key.len:
      if i >= p.key.len or p.key[i] != key[i]: return
  result = top
iterator keysWithPrefix*[T](c: CritBitTree[T], prefix: string, longestMatch = false): string =
  for x in allprefixedAux(c, prefix, longestMatch).leaves(): yield x.key
iterator valuesWithPrefix*[T](c: CritBitTree[T], prefix: string, longestMatch = false): T =
  for x in allprefixedAux(c, prefix, longestMatch).leaves(): yield x.val
proc `$`*[T](c: CritBitTree[T]): string =
  if c.len == 0:
    when T is void:
      result = "{}"
    else:
      result = "{:}"
  else:
    # an educated guess is better than nothing:
    when T is void:
      const avgItemLen = 8
    else:
      const avgItemLen = 16
    result = newStringOfCap(c.count * avgItemLen)
    result.add("{")
    when T is void:
      for key in keys(c):
        if result.len > 1: result.add(", ")
        result.addQuoted(key)
    else:
      for key, val in pairs(c):
        if result.len > 1: result.add(", ")
        result.addQuoted(key)
        result.add(": ")
        result.addQuoted(val)
    result.add("}")


when isMainModule:
  import unittest
  import strutils
  import times
  template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
  var xorShiftVar* = 88172645463325252.uint64
  xorShiftVar = cast[uint64](cpuTime()) # 初期値を固定しない場合
  proc xorShift() : uint64 =
    xorShiftVar = xorShiftVar xor (xorShiftVar shl 13)
    xorShiftVar = xorShiftVar xor (xorShiftVar shr 7)
    xorShiftVar = xorShiftVar xor (xorShiftVar shl 17)
    return xorShiftVar
  proc randomBit*(maxBit:int):int = # mod が遅い場合
    cast[int](xorShift() and cast[uint64]((1 shl maxBit) - 1))
  proc randomStringFast*(maxBit:int,kindBit:int=4):string =
    let size = 1 + randomBit(maxBit) # 長いのを大量に
    const A = 'A'.ord
    if kindBit > 4:
      var S = newSeq[char](size)
      for i in 0..<size: S[i] = cast[char](randomBit(kindBit) + A)
      return cast[string](S)
    else:
      result = ""
      for i in 0..<size: result.add cast[char](randomBit(kindBit) + A)
  # bench
  # import sets
  # stopwatch:
  #   block:
  #     echo "Raw"
  #     var S = 0
  #     for i in 0..<6e5.int:
  #       S += randomStringFast(3).len
  #     echo S
  # stopwatch:
  #   block:
  #     echo "HashSet"
  #     var S = initSet[string]()
  #     for i in 0..<1e6.int:
  #       S.incl randomStringFast(3,1)
  #     echo S.len
  stopwatch:
    block:
      echo "Patricia Tree"
      var S : CritBitTree[int]
      for i in 0..<1e6.int:
        S[randomStringFast(3,1)] = 123
      echo S.len

  # test "Patricia Tree":
  #   block: # キーの重複を許さないver
  #     var T : CritBitTree[int]
  #     echo T.len
  #     T.inc "aiueo"
  #     T.inc "aiueoeo"
  #     T.inc "aiueo"
  #     echo T.len
  #     echo "aiueo" in T
  #     echo "aiueoa" in T
  #     echo T
  #   block: # これはなんですか
  #     var T : CritBitTree[void]
  #     echo T.len
  #     T.incl "aiueo"
  #     T.incl "aiueoeo"
  #     T.incl "aiueo"
  #     echo T.len
  #   block: # これはTableですね
  #     var T : CritBitTree[char]
  #     echo T.len
  #     T["aiueo"] = 'x'
  #     T["aiueoeo"] = 'o'
  #     T["aiueo"] = 'c'
  #     echo T["aiueo"]
  #     T.excl "aiueo"
  #     echo "aiueo" in T
