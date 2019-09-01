import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord


# proc toCountTable*[A](keys: openArray[A]): CountTable[A] =
#   result = initCountTable[A](nextPowerOfTwo(keys.len * 3 div 2 + 4))
#   for key in items(keys):
#     result[key] = 1 + (if key in result : result[key] else: 0)
# for n in 4..12:
#   if n mod 2 == 1 : continue
#   var isB = newSeqWith(n,1)
#   var per = toSeq(0..(n-1))
#   var ans = newSeq[string]()
#   while true:
#     var isB2 = isB
#     var ok = true
#     for i in 0..<(n div 2):
#       let x = per[i]
#       let y = per[n - 1 - i]
#       if x > y :
#         ok = false
#         break
#       for j in x..y:
#         isB2[j] = 1 - isB2[j]
#     if ok:
#       ans .add isB2.mapIt($it).join("")
#     if not per.nextPermutation(): break
#   ans.sort(cmp)
#   echo ans.toCountTable()

const MOD = 1e9.int + 7
type ModInt = object
  v:int # 0~MODに収まる
proc toModInt*(a:int) : ModInt =
  if a < -MOD : result.v = ((a mod MOD) + MOD) mod MOD
  elif a < 0 : result.v = a + MOD
  elif a >= MOD: result.v = a mod MOD
  else: result.v = a
proc `+`*(a,b:ModInt) : ModInt =
  result.v = a.v + b.v
  if result.v >= MOD : result.v = result.v mod MOD
proc `*`*(a,b:ModInt) : ModInt =
  result.v = a.v * b.v
  if result.v >= MOD : result.v = result.v mod MOD
proc `^`*(a:ModInt,b:int) : ModInt =
  if a.v == 0 : return 0.toModInt()
  if b == 0 : return 1.toModInt()
  if b == 1 : return a
  if b > MOD: return a^(b mod (MOD-1)) # フェルマーの小定理
  let pow = a^(b div 2)
  if b mod 2 == 0 : return pow * pow
  return pow * pow * a
proc `+`*(a:int,b:ModInt) : ModInt = a.toModInt() + b
proc `+`*(a:ModInt,b:int) : ModInt = a + b.toModInt()
proc `-`*(a:ModInt,b:int) : ModInt = a + (-b)
proc `-`*(a,b:ModInt) : ModInt = a + (-b.v)
proc `-`*(a:int,b:ModInt) : ModInt = a.toModInt() + (-b.v)
proc `*`*(a:int,b:ModInt) : ModInt = a.toModInt() * b
proc `*`*(a:ModInt,b:int) : ModInt = a * b.toModInt()
proc `/`*(a,b:ModInt) : ModInt = a * b^(MOD-2)
proc `$`*(a:ModInt) : string = $a.v

let n = scan() # 10^5
var isW = newSeqWith(2 * n,getchar_unlocked() == 'W') # 全てWに
if isW[0] or isW[2*n-1]: quit "0",0
var base = 1.toModInt()
for i in 1..n: base = base * i
if isW.allIt(not it):
  echo base
  quit 0
base = base * 2
var ans = base
var t = 0
var iOK = true
for i in 1..<2*n-2:
  # i と i-1を反転
  if iOK and isW[i] :
    isW[i] = not isW[i]
    isW[i+1] = not isW[i+1]
    t += 1
  else:
    iOK = not iOK

# check
for i in 1..<2*n-1:
  if isW[i] :
    quit "0",0
ans = ans * t
echo ans


# var ans = newSeq[int]()
# var a = 0
# var b = 2 * n - 1
# n.times:
#   while a < 2 * n and isW[a] :
#     a += 1
#   while b >= 0 and isW[b]:
#     b -= 1
#   if a >= 2 * n or b < 0 :
#     quit "0",0
#   isW[a] = true
#   isW[b] = true

# n回のみ
# 2n個のうちn個選んで全てがBになるものを列挙(順番は問わないので?)
