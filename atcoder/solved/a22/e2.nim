import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues,times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord

# 軽量版 の ロリハ
# https://qiita.com/keymoon/items/11fac5627672a6d6a9f6
# 構築 O(|S|) / 部分文字列検索 O(1)
type LoliHa = ref object
  A: seq[int]  # baseA 進数表示
  AP: seq[int] # pow(baseA,n)
proc modMasked(a:int) : int =
  const mask61 = (1 shl 61) - 1
  var a = a
  if a < 0: a = (a + mask61 * 7) and mask61
  a = (a and mask61) + (a shr 61)
  if a > mask61 : a -= mask61
  return a
proc mulMasked(a,b:int) : int =
  const mask30 = (1 shl 30) - 1
  const mask31 = (1 shl 31) - 1
  let au = a shr 31
  let ad = a and mask31
  let bu = b shr 31
  let bd = b and mask31
  let mid = ad * bu + au * bd
  let midu = mid shr 30
  let midd = mid and mask30
  return (au * bu * 2 + ad * bd + midu + (midd shl 31)).modMasked()
proc newLoliHa(S:string) : LoliHa =
  # 67800 と 678 は 67800 == 678 * 100 で得られる
  const LH_BASE = 123804440394837511.int # ランダムに取れば落ちても落ちない
  new(result)
  result.A = newSeq[int](S.len + 1)
  result.AP = newSeq[int](S.len + 1)
  result.AP[0] = 1
  for i in 0..<S.len:
    result.A[i+1] = (result.A[i].mulMasked(LH_BASE) + S[i].ord).modMasked()
    result.AP[i+1] = result.AP[i].mulMasked(LH_BASE)
proc hash(self:LoliHa,slice:Slice[int]): int =
  let l = slice.a
  let r = slice.b + 1
  return (self.AP[r-l].mulMasked(self.A[l]) - self.A[r]).modMasked()


discard scan()
let S = stdin.readLine()
var LH = newLoliHa(S)
for length in (S.len div 2).countdown(1):
  var pos = initTable[int,int]()
  for i in 0..S.len-length:
    var h = LH.hash(i..<i+length)
    if h in pos:
      let pre = pos[h]
      if i - pre >= length:
        echo length
        quit 0
    else:
      pos[h] = i
echo 0
