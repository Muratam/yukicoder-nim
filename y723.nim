import sequtils,strutils,algorithm,math,sugar,macros,strformat
import tables
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  var minus = false
  while true:
    var k = getchar_unlocked()
    if k == '-' : minus = true
    elif k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord
  if minus: result *= -1
template times*(n:int,body) = (for _ in 0..<n: body)

let n = scan()
let x = scan()
var A: array[10_0010,int]
n.times : A[scan()] += 1
var ans = 0
for i in 0..10_0000:
  if x-i >= 0 and x-i <= 10_0000 and A[i] > 0 and A[x-i] > 0:
    ans += A[i] * A[x-i]
echo ans






#[
import sequtils,strutils,algorithm,math,sugar,macros,strformat
import tables
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  var minus = false
  while true:
    var k = getchar_unlocked()
    if k == '-' : minus = true
    elif k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord
  if minus: result *= -1
proc toCountSeq[T](x:seq[T]) : seq[tuple[k:T,v:int]] = toSeq(x.toCountTable().pairs)

let n = scan()
let x = scan()
var A = newSeq[int](n)
for i in 0..<n:A[i] = scan()
let KV = A.toCountSeq().sorted(cmp)
let K = KV.mapIt(it.k)
let V = KV.mapIt(it.v)
var ans = 0
for ik,k in K:
  let i = K.lowerBound(x-k)
  if K[i] + k == x : ans += V[i]*V[ik]
echo ans
]#