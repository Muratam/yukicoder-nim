{.overflowChecks:off.}
import times,strutils,sequtils
proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc scan(): int = scanf("%lld\n",addr result)

const n  = 1_0000_000
# なるべく定数最適化されないように標準入力からとる
var a = scan()
var b = scan()
var c = 10
let aIn = a
let bIn = b
let cIn = c
var t = 0.0
template timer(name:string,rate:int,offset:float,body) =
  a = aIn
  b = bIn
  c = cIn
  let t1 = cpuTime()
  body
  t = (cpuTime() - t1) * 1000 * rate - offset
  let p1 = if a > 1e9.int: " " else: "."
  let p2 = if b > 1e9.int: " " else: "."
  let p3 = if c > 1e9.int: " " else: "."
  echo p1,p2,p3, name," | ", t.int,"ms"

# 基本演算は 0.5 ~ 2 倍くらいしか変わらないのでほとんど気にしなくて良い
#   + - ^ & | は 全て同じくらいの速度. 定数加算はもっとはやい
#   cast(safe/unsafe, <=) は 2~3倍くらい速い。どの書き方でも最適化してくれる
#   掛け算は一応 2~3 倍くらい遅い.
#   div 2^n は shr n と書かないと2倍くらい遅い.でもその程度.
#   CPU命令として実装されているBit演算(ctzなど)は1~2倍くらい遅いがその程度.

# 以下の演算はきちんと気をつける
# 10~30倍くらい遅い:
#   malloc(一括) / memload / memstore
# 30倍くらい遅い:
#   割り算 / sqrt / ダブリングを使うbit演算
# 100倍くらい遅い:
#   malloc(動的)
# 1000倍くらい遅い:
#   時間計測

# 構造体を扱う時は以下に気をつける
# TLDR: (int以上のことをする時は) ref obj で管理し、
#   可能なら配列から取り出したりせずにそのまま扱う。
# malloc は intそのままよりも 1~2倍遅い. ref の方が速い。
# 実体化(var x = S[i]) は そのまま処理をするよりも遅いので,愚直な書き方をすべき
#   ref 系だと2倍程度
#   非ref だと20倍程度
# S[i] と書いたときも、 非ref の方が更に2倍くらい速い

timer(" = ",1,0.0):
  for i in 0..<n div 3:
    a = b
    b = c
    c = a
timer(" + ",1,0.0):
  for i in 0..<n div 3:
    a = b + c
    b = c + a
    c = a + b
timer(" - ",1,0.0):
  for i in 0..<n div 3:
    a = b - c
    b = c - a
    c = a - b
let subT = t
timer(" * ",1,0.0):
  for i in 0..<n div 3:
    a = b * c
    b = c * a
    c = a * b
timer(" | - ",1,subT):
  for i in 0..<n div 3:
    a = b - c
    b = c or a
    c = a - b
    a = b or c
    b = c - a
    c = a or b
timer(" ^ - ",1,subT):
  for i in 0..<n div 3:
    a = b - c
    b = c xor a
    c = a - b
    a = b xor c
    b = c - a
    c = a xor b
timer(" & - ",1,subT):
  for i in 0..<n div 3:
    a = b - c
    b = c and a
    c = a - b
    a = b and c
    b = c - a
    c = a and b
timer(" << -",1,subT):
  for i in 0..<n div 3:
    a = b - c
    b = c shl a
    c = a - b
    a = b shl c
    b = c - a
    c = a shl b
timer(" >> -",1,subT):
  for i in 0..<n div 3:
    a = b - c
    b = c shr a
    c = a - b
    a = b shr c
    b = c - a
    c = a shr b
timer(" cast -",1,subT):
  # 安全なキャストなので最新のNimでは失敗してくれるためにテストにならない
  # 0.13 でも 非Release時はチェックする
  # when NimMajor * 100 + NimMinor < 18:
  if false:
    for i in 0..<n div 3:
      b = b.bool.int
      a = b - c
      c = c.bool.int
      c = a - b
      a = a.bool.int
      b = c - a
timer(" cast -",1,subT):
  for i in 0..<n div 3:
    b = cast[int](cast[bool](b))
    a = b - c
    c = cast[int](cast[bool](c))
    c = a - b
    a = cast[int](cast[bool](a))
    b = c - a
timer(" >= -",1,subT):
  for i in 0..<n div 3:
    b = if b > 0 : 1 else: 0
    a = b - c
    c = if c > 0 : 1 else: 0
    c = a - b
    a = if a > 0 : 1 else: 0
    b = c - a
timer(" / 2  *",1,subT):
  for i in 0..<n div 3:
    a = b * c
    a = a div 2
    b = c * a
    b = b div 2
    c = a * b
    c = c div 2
timer(" / 10 *",1,subT):
  for i in 0..<n div 3:
    a = b * c
    a = a div 10
    b = c * a
    b = b div 10
    c = a * b
    c = c div 10
timer(" >> 4 *",1,subT):
  for i in 0..<n div 3:
    a = b * c
    a = a shr 4
    b = c * a
    b = b shr 4
    c = a * b
    c = c shr 4
timer(" if + ",1,0.0):
  for i in 0..<n div 3:
    if c == 0 : c = 10
    a = b + c
    if a == 0 : a = 10
    b = c + a
    if b == 0 : b = 10
    c = a + b
# ビット演算. サポートされているかは環境による
# 対応していない場合
timer(" popcount - ",1,subT):
  proc popcount(x: culonglong): cint {.importc: "__builtin_popcountll", cdecl.}
  for i in 0..<n div 3:
    a = b + c
    a = cast[culonglong](a).popcount()
    b = c + a
    b = cast[culonglong](b).popcount()
    c = a + b
    c = cast[culonglong](c).popcount()
timer(" clz - ",1,subT):
  proc countLeadingZeroBits(x: culonglong): cint {.importc: "__builtin_clzll", cdecl.}
  for i in 0..<n div 3:
    a = b + c
    a = cast[culonglong](a).countLeadingZeroBits()
    b = c + a
    b = cast[culonglong](b).countLeadingZeroBits()
    c = a + b
    c = cast[culonglong](c).countLeadingZeroBits()
timer(" ctz - ",1,subT):
  proc countTrailingZeroBits(x: culonglong): cint {.importc: "__builtin_ctzll", cdecl.}
  for i in 0..<n div 3:
    a = b + c
    a = cast[culonglong](a).countTrailingZeroBits()
    b = c + a
    b = cast[culonglong](b).countTrailingZeroBits()
    c = a + b
    c = cast[culonglong](c).countTrailingZeroBits()
timer(" doubling - ",1,subT):
  proc doubling(a:int):int =
    var m = cast[uint64](a)
    m = m or (m shr 32)
    m = m or (m shr 16)
    m = m or (m shr 8)
    m = m or (m shr 4)
    m = m or (m shr 2)
    m = m or (m shr 1)
    return cast[int](not m)
  for i in 0..<n div 3:
    a = b + c
    a = a.doubling()
    b = c + a
    b = b.doubling()
    c = a + b
    c = c.doubling()
timer(" doubling inline - ",1,subT):
  proc doublingInline(a:int):int {.inline,noSideEffect.} =
    var m = cast[uint64](a)
    m = m or (m shr 32)
    m = m or (m shr 16)
    m = m or (m shr 8)
    m = m or (m shr 4)
    m = m or (m shr 2)
    m = m or (m shr 1)
    return cast[int](not m)
  for i in 0..<n div 3:
    a = b + c
    a = a.doublingInline()
    b = c + a
    b = b.doublingInline()
    c = a + b
    c = c.doublingInline()

# 10~100倍の壁 :
# 除算
timer(" if / ",10,0.0):
  for i in 0..<n div 30:
    if c == 0 : c = 10
    a = b div c
    if a == 0 : a = 10
    b = c div a
    if b == 0 : b = 10
    c = a div b
# 平方根
import math
timer(" sqrt ",1,0.0):
  for i in 0..<n div 3:
    a = b + c
    a = a.float.sqrt.int
    b = c + a
    b = b.float.sqrt.int
    c = a + b
    c = c.float.sqrt.int

# メモリアクセス
let tMask = 0xffff # 65536
let T = toSeq(0..tMask)
timer(" memory + ",1,0.0):
  for i in 0..<n div 3:
    a = T[b and tMask] + T[c and tMask]
    b = T[c and tMask] + T[a and tMask]
    c = T[a and tMask] + T[b and tMask]
timer(" malloc sq",1,0.0):
  block:
    let sqn = n.float.sqrt.int
    let sqna = sqn # sqn
    let sqnb = n div sqna
    var S = @[0,1]
    for i in 0..<sqna :
      S = @[i,i+1]
      for j in 0..<sqnb:
        S.add S[^1] + S[^2]
    a = S[^1]
timer(" malloc adding",1,0.0):
  block:
    var S = @[0,1]
    for _ in 0..<n:
      S.add S[^1] + S[^2]
    a = S[^1]
timer(" malloc direct",1,0.0):
  block:
    var S = newSeq[int](n+10)
    S[1] = 1
    for i in 0..<n:
      S[i+2] = S[i] + S[i+1]
    a = S[n]
# 構造体のメモリアクセス
type
  # nodeを更に増やしたり(両端)、
  # int を更に増やしたり(データ量増加)してもほとんど速度は変わらない
  NodeObj = object
    pre : ref NodeObj
    index : int
  Node = ref object
    pre : Node
    index : int
proc newNode(index:int) :Node=
  new(result)
  result.index = index
  # result.pre = pre # 参照の更新も意外と時間がかかる(多分GCのせい)
timer(" malloc int",100,0.0):
  var MI = newSeq[int]()
  for i in 0..<n div 100:
    MI.add i
let intMallocTime = t
timer(" malloc ref node",100,intMallocTime):
  var MR = newSeq[Node]()
  for i in 0..<n div 100:
    MR.add newNode(i)
timer(" malloc node",100,intMallocTime):
  var MN = newSeq[NodeObj]()
  for i in 2..<n div 100:
    var s : NodeObj
    s.index = i
    MN.add s
timer(" access Sum ",100,0.0):
  for i in 0..<MI.len:
    a += MI[i]
timer(" access ref node with assign",100,0.0):
  for i in 0..<MR.len:
    let x = MR[i]
    a += x.index
timer(" access node with assign",100,0.0):
  for i in 0..<MN.len:
    let x = MN[i]
    a += x.index
timer(" access ref node",100,0.0):
  for i in 0..<MR.len:
    a += MR[i].index
timer(" access node ",100,0.0):
  for i in 0..<MN.len:
    a += MN[i].index


# 100~1000倍の壁 : 計測
timer(" time ",100,0.0):
  let tt = cpuTime()
  for i in 0..<n div 100:
    a += (cpuTime() - tt).int
