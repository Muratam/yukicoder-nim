import sequtils,algorithm,strutils,intsets,tables,sugar
template times*(n:int,body) = (for _ in 0..<n: body)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
proc printInt(a:int32) =
  if a == 0:
    putchar_unlocked('0')
    return
  template div10(a:int32) : int32 = cast[int32]((0x1999999A * cast[int64](a)) shr 32)
  template mod10(a:int32) : int32 = a - (a.div10 * 10)
  var n = a
  var rev = a
  var cnt = 0
  while rev.mod10 == 0:
    cnt += 1
    rev = rev.div10
  rev = 0
  while n != 0:
    rev = rev * 10 + n.mod10
    n = n.div10
  while rev != 0:
    putchar_unlocked((rev.mod10 + '0'.ord).chr)
    rev = rev.div10
  while cnt != 0:
    putchar_unlocked('0')
    cnt -= 1
proc printInt(a:int,last:char) =
  a.int32.printInt()
  putchar_unlocked(last)




let n = scan()
let m = scan()
let k = scan()
var A : array[1001,int]
var B : array[1001,int]
var C : array[1001,int]
for i in 0..<m:
  A[i] = scan()
  B[i] = scan()
  C[i] = scan()
var oks : array[101,bool]
var nexts : array[101,bool]
for i in 1..n: oks[i] = true
k.times:
  let d = scan()
  for i in 0..<m:
    if C[i] != d : continue
    nexts[A[i]] = nexts[A[i]] or oks[B[i]]
    nexts[B[i]] = nexts[B[i]] or oks[A[i]]
  for i in 1..n:
    oks[i] = nexts[i]
    nexts[i] = false

var ans = 0
for i in 1..n:
  if oks[i] : ans += 1
printInt(ans,'\n')
for i in 1..n:
  if oks[i] : printInt(i,' ')
putchar_unlocked('\n')