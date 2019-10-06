# 標準ライブラリにパトリシア木があるのでそれをモノイドに拡張したい
# unit / apply を定義して,
# S["aiueo"] = 30, S["aiueoeo"] = 50
# S["aiueo"] == 30, S["aiu*"] == 80 , みたいな
include "system/inclrtl"
type
  PatriciaNodeObj[T] = object # {.acyclic.}
    pos: int
    otherBits: char
    val: T
    case isLeaf: bool
    of false:
      child: array[0..1, PatriciaNode[T]]
    of true:
      key: string
  PatriciaNode[T] = ref PatriciaNodeObj[T]
  PatriciaTree*[T] = ref object
    root: PatriciaNode[T]
    count: int
    unit*: T
    apply*:proc(x,y:T):T
proc newPatriciaTree*[T](apply:proc(x,y:T):T,unit:T) : PatriciaTree[T] =
  new(result)
  result.root = nil
  result.unit = unit
  result.apply = apply
proc len*[T](c: PatriciaTree[T]): int =  c.count
# キーに完全一致するものを取得
proc rawGet[T](c: PatriciaTree[T], key: string): PatriciaNode[T] =
  echo "GET:",key
  var it = c.root
  while it != nil:
    echo "get:",key,"->",it.key
    if it.isLeaf:
      return if it.key == key: it else: nil
    let ch = if it.pos < key.len: key[it.pos] else: '\0'
    let dir = (1 + (ch.ord or it.otherBits.ord)) shr 8
    it = it.child[dir]
proc contains*[T](c: PatriciaTree[T], key: string): bool {.inline.} =
  c.rawGet(key) != nil
proc exclImpl[T](c: var PatriciaTree[T], key: string): int =
  var p = c.root
  var wherep = addr(c.root)
  var whereq: ptr PatriciaNode[T] = nil
  if p == nil: return c.count
  var dir = 0
  var q: PatriciaNode[T]
  while not p.isLeaf:
    whereq = wherep
    q = p
    let ch = if p.pos < key.len: key[p.pos] else: '\0'
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
proc excl*[T](c: var PatriciaTree[T], key: string) = discard exclImpl(c, key)
proc `[]=`*[T](c: var PatriciaTree[T], key: string, val: T) =
  if c.root == nil:
    c.root = PatriciaNode[T](isleaf: true, key: key)
    c.count += 1
    c.root.val = val
    return
  var it = c.root
  while not it.isLeaf:
    let ch = if it.pos < key.len: key[it.pos] else: '\0'
    let dir = (1 + (ch.ord or it.otherBits.ord)) shr 8
    it = it.child[dir]
  var newOtherBits = 0
  var newpos = 0
  block blockX:
    while newpos < key.len:
      let ch = if newpos < it.key.len: it.key[newpos] else: '\0'
      if ch != key[newpos]:
        newOtherBits = ch.ord xor key[newpos].ord
        break blockX
      newpos += 1
    if newpos < it.key.len:
      newOtherBits = it.key[newpos].ord
    else: # 既に葉があった
      it.val = val
      return
  while (newOtherBits and (newOtherBits-1)) != 0:
    newOtherBits = newOtherBits and (newOtherBits-1)
  newOtherBits = newOtherBits xor 255
  let ch = if newpos < it.key.len: it.key[newpos] else: '\0'
  let dir = (1 + (ord(ch) or newOtherBits)) shr 8
  var inner = PatriciaNode[T](isLeaf:false,pos:newpos,otherBits:chr(newOtherBits))
  let resNode = PatriciaNode[T](isLeaf: true, key: key)
  inner.child[1 - dir] = resNode
  var wherep = addr(c.root)
  while true:
    var p = wherep[]
    if p.isLeaf: break
    if p.pos > newpos: break
    if p.pos == newpos and p.otherBits.ord > newOtherBits: break
    let ch = if p.pos < key.len: key[p.pos] else: '\0'
    let dir = (1 + (ch.ord or p.otherBits.ord)) shr 8
    wherep = addr(p.child[dir])
  inner.child[dir] = wherep[]
  wherep[] = inner
  c.count += 1
  resNode.val = val

proc `[]`*[T](c: PatriciaTree[T], key: string): T {.inline.} = rawGet(c, key).val
proc `[]`*[T](c: var PatriciaTree[T], key: string): var T {.inline.} = rawGet(c, key).val
iterator leaves[T](n: PatriciaNode[T]): PatriciaNode[T] =
  if n != nil:
    var stack = @[n]
    while stack.len > 0:
      var it = stack.pop
      while not it.isLeaf:
        stack.add(it.child[1])
        it = it.child[0]
        assert(it != nil)
      yield it
iterator keys*[T](c: PatriciaTree[T]): string =
  for x in leaves(c.root): yield x.key
iterator values*[T](c: PatriciaTree[T]): T =
  for x in leaves(c.root): yield x.val
proc allprefixedAux[T](c: PatriciaTree[T], key: string, longestMatch: bool): PatriciaNode[T] =
  var p = c.root
  var top = p
  if p == nil: return nil
  while not p.isLeaf:
    var q = p
    let ch = if p.pos < key.len: key[p.pos] else: '\0'
    let dir = (1 + (ch.ord or p.otherBits.ord)) shr 8
    p = p.child[dir]
    if q.pos < key.len: top = p
  if not longestMatch: # このfilterはなに？
    if key.len > p.key.len : return
    for i in 0 ..< key.len:
      if p.key[i] != key[i]: return
  result = top
iterator keysWithPrefix*[T](c: PatriciaTree[T], prefix: string, longestMatch = false): string =
  for x in allprefixedAux(c, prefix, longestMatch).leaves(): yield x.key
iterator valuesWithPrefix*[T](c: PatriciaTree[T], prefix: string, longestMatch = false): T =
  for x in allprefixedAux(c, prefix, longestMatch).leaves(): yield x.val
proc `$`*[T](c: PatriciaTree[T]): string =
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
  test "Monoidic Patricia Tree":
    var S = newPatriciaTree(proc(x,y:int):int=x+y,0)
    S["aiueo"] = 10
    S["aiueoao"] = 20
    S["aaaea"] = 30
    check: "aiueoao" in S
    check: S.len == 3
    check: S["aiueo"] == 10 and S["aiueoao"] == 20
    S["aiueoao"] = 30
    check: S["aiueo"] == 10 and S["aiueoao"] == 30
    S["aiueo"] = 20
    check: S["aiueo"] == 20 and S["aiueoao"] == 30
    for s in S.keysWithPrefix("aiueoao"): echo s
    echo "--"
    for s in S.keysWithPrefix("aiueoao",true): echo s
    S.excl "aiueo"
    check: S.len == 2
