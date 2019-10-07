import sequtils
# まず multiset と同じく, 追加・削除・キーの最{大,小}値 ができる
# 非負整数のときのセグツリと化した 2進パトリシア木.
type
  PatriciaSegmentNode[T] = ref object
    to0,to1 : PatriciaSegmentNode[T]
    isLeaf : bool
    count : int32
    valueOrMask : int # 葉なら value / 枝なら一番下位bitが自身が担当するbit番号.それ以外はprefix
    data : T
  PatriciaSegmentTree[T] = object
    root : PatriciaSegmentNode[T]
    unit : T
    apply*:proc(x,y:T):T
proc newPatriciaSegmentNode*[T](self:PatriciaSegmentTree[T]):PatriciaSegmentNode[T] =
  new(result)
  result.data = self.unit
# 葉を生成
proc newPatriciaSegmentLeaf[T](self:PatriciaSegmentTree[T],n:int,val:T) : PatriciaSegmentNode[T] =
  new(result)
  result.isLeaf = true
  result.valueOrMask = n
  result.count = 1
  result.data = val
proc newPatriciaSegmentTree*[T](apply:proc(x,y:T):T,unit:T,bitSize:int = 60):PatriciaSegmentTree[T] =
  result.unit = unit
  result.apply = apply
  result.root = result.newPatriciaSegmentNode()
  result.root.count = 0
  result.root.isLeaf = false
  result.root.valueOrMask = 1 shl bitSize
when NimMajor * 100 + NimMinor >= 18: import bitops
else:
  proc countLeadingZeroBits(x: culonglong): cint {.importc: "__builtin_clzll", cdecl.}
  proc countTrailingZeroBits(x: culonglong): cint {.importc: "__builtin_ctzll", cdecl.}
  proc fastLog2(x:culonglong):cint = 63 - countLeadingZeroBits(x)

proc bitSize*[T](self:PatriciaSegmentNode[T]):int =
  self.valueOrMask.culonglong.countTrailingZeroBits.int
proc len*[T](self:PatriciaSegmentTree[T]) : int = self.root.count
proc isTo1*[T](self:PatriciaSegmentNode[T],n:int):bool{.inline.} =
  let x = self.valueOrMask
  result = (x and n) == x
   # 上位bitは同じはずなので

# デバッグ用
import strutils
proc binary*(x:int,fill:int=0):string = # 二進表示
  if x == 0 : return "0".repeat(fill)
  if x < 0  : return binary(int.high+x+1,fill)
  result = ""
  var x = x
  while x > 0:
    result .add chr('0'.ord + x mod 2)
    x = x div 2
  for i in 0..<result.len div 2: swap(result[i],result[result.len-1-i])
  if result.len >= fill: return result[^fill..^1]
  return "0".repeat(0.max(fill - result.len)) & result
proc dump*[T](self:PatriciaSegmentNode[T],indent:int = 0) : string =
  if self == nil : return ""
  result = ""
  result .add self.valueOrMask.binary(60)
  result .add "\t"
  result .add $self.count
  result .add " "
  result .add $self.data
  result .add " "
  for i in 0..<indent: result .add "  "
  if self.isLeaf: result.add "_"
  else: result.add "|"
  result = result & "\n"
  if self.isLeaf: return
  if self.to0 != nil: result.add self.to0.dump(indent + 1)
  if self.to1 != nil: result.add self.to1.dump(indent + 1)
proc dump*[T](self:PatriciaSegmentTree[T]) : string = self.root.dump()

# 完全一致検索
var cnt = 0
# たかだか 2e7 回
proc `in`*[T](n:int,self:PatriciaSegmentTree[T]) : bool =
  var now = self.root
  while not now.isLeaf:
    cnt += 1
    if now.isTo1(n):
      if now.to1 == nil : return false
      now = now.to1
    else:
      if now.to0 == nil : return false
      now = now.to0
  return now.valueOrMask == n

# 中間点を生成
proc createInternalNode[T](self:var PatriciaSegmentTree[T],now:PatriciaSegmentNode,preTree:PatriciaSegmentNode,n:int,val:T) : PatriciaSegmentNode[T] =
  let cross = preTree.valueOrMask xor n
  var bit = 0
  # 頑張れば bit 演算にできそう.
  for bitI in (now.bitSize() - 1).countdown(0):
    if (cross and (1 shl bitI)) == 0 : continue
    bit = bitI
  var newLeaf = self.newPatriciaSegmentLeaf(n,val)
  var created = self.newPatriciaSegmentNode()
  created.isLeaf = false
  let n1 = preTree.valueOrMask
  let n2 = newLeaf.valueOrMask
  # fastLog2 は (n and -n)で累乗にできるね
  let n3 = 1 shl (n1 xor n2).culonglong.fastLog2()
  created.valueOrMask = (n1 or n2) and (not (n3 - 1))
  created.count = newLeaf.count + preTree.count
  if created.isTo1(newLeaf.valueOrMask):
    created.to1 = newLeaf
    created.to0 = preTree
  else:
    created.to1 = preTree
    created.to0 = newLeaf
  return created

proc `[]=`[T](self:var PatriciaSegmentTree[T],n:int,val:T) =
  var existsKey = n in self
  var now = self.root
  var target : PatriciaSegmentNode[T] = nil
  var path = @[now]
  while true:
    if not existsKey : now.count += 1
    let nowIsTo1 = now.isTo1(n)
    if nowIsTo1: target = now.to1
    else: target = now.to0
    proc backwardFromLeaf(self:var PatriciaSegmentTree[T],updateNow:bool = true) =
      if updateNow:
        if nowIsTo1: now.to1 = target
        else: now.to0 = target
      path.add target
      for i in (path.len-1).countdown(0):
        if path[i].to0 == nil:
          if path[i].to1 == nil: continue
          path[i].data = path[i].to1.data
        elif path[i].to1 == nil:
          path[i].data = path[i].to0.data
        else:
          path[i].data = self.apply(path[i].to0.data,path[i].to1.data)
      # self.backward(path)
    # ノードを見ていく
    if target == nil:
      # この先が空なので直接葉を作る
      target = self.newPatriciaSegmentLeaf(n,val)
      self.backwardFromLeaf()
      return
    elif target.isLeaf:
      let existsLeaf = target.valueOrMask == n
      if existsLeaf: # 葉があった
        if not existsKey : target.count += 1
        target.data = val
      else:
        target = self.createInternalNode(now,target,n,val)
      self.backwardFromLeaf(not existsLeaf)
      return
    else:
      let x = target.valueOrMask
      let mask = not(x xor (x - 1))
      # prefix が違ったので新しくそこに作る
      if (x and mask) != (n and mask) :
        target = self.createInternalNode(now,target,n,val)
        self.backwardFromLeaf()
        return
      path.add target
      now = target
# 完全一致
proc `[]`*[T](self:PatriciaSegmentTree[T],n:int) : T =
  var now = self.root
  while not now.isLeaf:
    if now.isTo1(n):
      if now.to1 == nil :
        return self.unit
      now = now.to1
    else:
      if now.to0 == nil :
        return self.unit
      now = now.to0
  if now.valueOrMask == n:
    return now.data
  return self.unit


import times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
import "../../mathlib/random"
block:
  var T = newPatriciaSegmentTree(proc(x,y:string):string = x&y,"")
  T[6] = "A"
  T[3] = "B"
  T[0] = "C"
  T[7] = "D"
  T[7] = "E"
  T[15] = "F"
  T[0] = "G"
  echo T.dump()
block:
  # 1e6のランダムケースで
  # 1000ms: std::set[int]()  なので、
  # 7倍のコストでセグツリができるならまあよいのでは
  stopwatch:
    var T = newPatriciaSegmentTree(proc(x,y:int):int = x+y,0)
    for i in 0..<1e5.int:
      T[randomBit(32)] = randomBit(32)
    echo T[0]
    echo cnt
