import sequtils
# 本質的には、 multiset と同じく, 追加・削除・極値系全部 ができる
# 非負整数のときのセグツリと化した 2進パトリシア木.
type
  PatriciaNode[T] = ref object
    to0,to1 : PatriciaNode[T]
    isLeaf : bool
    count : int32
    valueOrMask : int # 葉なら value / 枝なら一番下位bitが自身が担当するbit番号.それ以外はprefix
    data : T
  PatriciaTree[T] = ref object
    root : PatriciaNode[T]
    unit : T
    apply*:proc(x,y:T):T
proc newPatriciaNode*[T](self:PatriciaTree[T]):PatriciaNode[T] =
  new(result)
  result.data = self.unit
proc newPatriciaTree*[T](apply:proc(x,y:T):T,unit:T,bitSize:int = 60):PatriciaTree[T] =
  new(result)
  result.unit = unit
  result.apply = apply
  result.root = result.newPatriciaNode()
  result.root.count = 0
  result.root.isLeaf = false
  result.root.valueOrMask = 1 shl bitSize
when NimMajor * 100 + NimMinor >= 18: import bitops
else:
  proc countLeadingZeroBits(x: culonglong): cint {.importc: "__builtin_clzll", cdecl.}
  proc countTrailingZeroBits(x: culonglong): cint {.importc: "__builtin_ctzll", cdecl.}
  proc fastLog2(x:culonglong):cint = 63 - countLeadingZeroBits(x)

proc bitSize*[T](self:PatriciaNode[T]):int =
  self.valueOrMask.culonglong.countTrailingZeroBits.int
proc len*[T](self:PatriciaTree[T]) : int = self.root.count
proc isTo1*[T](self:PatriciaNode[T],n:int):bool{.inline.} =
  (self.valueOrMask and n) == self.valueOrMask # 上位bitは同じはずなので

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
proc dump*[T](self:PatriciaNode[T],indent:int = 0) : string =
  if self == nil : return ""
  result = ""
  result .add self.valueOrMask.binary(60)
  result .add "\t"
  result .add $self.count
  for i in 0..<indent: result .add "  "
  if self.isLeaf: result.add "_"
  else: result.add "|"
  result = result & "\n"
  if self.isLeaf: return
  if self.to0 != nil: result.add self.to0.dump(indent + 1)
  if self.to1 != nil: result.add self.to1.dump(indent + 1)
proc dump*[T](self:PatriciaTree[T]) : string = self.root.dump()

# 完全一致検索
proc `in`*(n:int,self:PatriciaTree) : bool =
  var now = self.root
  while not now.isLeaf:
    if now.isTo1(n):
      if now.to1 == nil : return false
      now = now.to1
    else:
      if now.to0 == nil : return false
      now = now.to0
  return now.valueOrMask == n
# 中間点を生成
proc createInternalNode[T](self:PatriciaTree[T],now:PatriciaNode,preTree:PatriciaNode,n:int,val:T) : PatriciaNode[T] =
  let cross = preTree.valueOrMask xor n
  var bit = 0
  # 頑張れば bit 演算にできそう.
  for bitI in (now.bitSize() - 1).countdown(0):
    if (cross and (1 shl bitI)) == 0 : continue
    bit = bitI
  var newLeaf = self.newPatriciaNode()
  newLeaf.isLeaf = true
  newLeaf.valueOrMask = n
  newLeaf.count = 1
  var created = self.newPatriciaNode()
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

proc `[]=`[T](self:var PatriciaTree[T],n:int,val:T) =
  var existsKey = n in self
  var now = self.root
  var target : PatriciaNode[T] = nil
  while true:
    if not existsKey : now.count += 1
    let nowIsTo1 = now.isTo1(n)
    if nowIsTo1: target = now.to1
    else: target = now.to0
    var created : PatriciaNode[T] = nil
    # ノードを見ていく
    if target == nil:
      # この先が空なので直接葉を作る
      created = self.newPatriciaNode()
      created.isLeaf = true
      created.valueOrMask = n
      created.count = 1
    elif target.isLeaf:
      if target.valueOrMask == n: # 葉があった
        if not existsKey : target.count += 1
        target.data = val
        return
      created = self.createInternalNode(now,target,n,val)
    else:
      let x = target.valueOrMask
      let mask = not(x xor (x - 1))
      # prefix が違ったので新しくそこに作る
      if (x and mask) != (n and mask) :
        created = self.createInternalNode(now,target,n,val)
    if created != nil :
      if nowIsTo1:now.to1 = created
      else:now.to0 = created
      return
    now = target


import times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
import "../../mathlib/random"
var T = newPatriciaTree(proc(x,y:int):int = x + y,0)
T[0b0110] = 10
T[0b0111] = 20
T[0b011] = 30
T[0b0] = 40
echo T.dump()
# echo T["aiu"]
